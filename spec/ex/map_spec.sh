Describe 'sx_ex_map'
  Include ./sx.sh

  Describe '名前をステータス数値に解決すること'
    It 'OK を 0 に解決すること'
      When call sx_ex_map s OK
      The status should be success
      The variable s should equal 0
    End

    It 'DATAERR を 65 に解決すること'
      When call sx_ex_map s DATAERR
      The status should be success
      The variable s should equal 65
    End
  End

  Describe 'ステータス数値を名前に解決すること'
    It '0 を OK に解決すること'
      When call sx_ex_map s 0
      The status should be success
      The variable s should equal 'OK'
    End

    It '65 を DATAERR に解決すること'
      When call sx_ex_map s 65
      The status should be success
      The variable s should equal 'DATAERR'
    End

    It 'ステータスに対応する名前がない場合は SX_EX_USAGE (64) を返すこと'
      When call sx_ex_map s 1
      The status should equal 64
    End
  End

  Describe 'バリデーション'
    It 'マップにない数値ステータス 255 を拒否すること'
      When call sx_ex_map s 255
      The status should equal 64
    End

    It '無効なステータス 256 を拒否すること'
      When call sx_ex_map s 256
      The status should equal 64
    End

    It '未知の名前を拒否すること'
      When call sx_ex_map s UNKNOWN_NAME
      The status should equal 64
    End

    It '代入なしでも有効な名前を受け入れること'
      When call sx_ex_map : OK
      The status should be success
    End

    It '代入なしでも有効な数値ステータスを受け入れること'
      When call sx_ex_map : 0
      The status should be success
    End
  End

  Describe 'エラーハンドリング'
    It '無効な変数名に対して EX_USAGE (64) を返すこと'
      When call sx_ex_map '1var' OK
      The status should equal 64
    End

    It '読み取り専用変数に対して EX_NOPERM (77) を返すこと'
      readonly ro_var=0
      When call sx_ex_map ro_var OK
      The status should equal 77
    End
  End

  Describe '複数の引数'
    It '複数の変数を解決し、変数名を検証すること'
      When call sx_ex_map s1:s2 OK 65
      The status should be success
      The variable s1 should equal 0
      The variable s2 should equal 'DATAERR'
    End

    It 'いずれかの値が無効な場合に失敗すること'
      When call sx_ex_map s1:s2 OK INVALID
      The status should equal 64
    End

    It 'いずれかの変数名が無効な場合に失敗すること'
      When call sx_ex_map 's1:2s' OK 65
      The status should equal 64
    End

    It '単一の変数に複数の引数を解決し、スペース区切りで格納すること'
      When call sx_ex_map s OK DATAERR
      The status should be success
      The variable s should equal '0 65'
    End
  End

  Describe '高速モード (SX_CFG_SKIP_CHK=1)'
    It 'バリデーションをスキップして名前を解決すること'
      SX_CFG_SKIP_CHK=1
      When call sx_ex_map s OK
      The status should be success
      The variable s should equal 0
    End

    It '未知の名前に対しても (内部的には) 処理が継続されるがマッピングされない'
      # 注: 現在の実装では __sx_ex_map はマッピングできない場合そのまま値を返す
      SX_CFG_SKIP_CHK=1
      When call sx_ex_map s UNKNOWN
      The status should be success
      The variable s should equal 'UNKNOWN'
    End
  End
End
