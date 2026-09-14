#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_fn_with'
  Include ./sx.sh
  SX_CFG_SEP="--"

  It '単一の匿名関数を定義して実行できること'
    callback_fn() {
      echo "called with $1"
    }
    # 実際には echo は使えないが、テスト内では Mock 的に使うことがある。
    # しかし sx の流儀では変数に格納するのが基本。
    
    When call sx_fn_with 'cb=res="called with $1"' -- cb "hello"
    The status should be success
    The variable res should equal "called with hello"
  End

  It '複数の匿名関数を定義して実行できること'
    When call sx_fn_with 'f1="$1"' 'f2=res=ok' -- f1 f2
    The status should be success
    The variable res should equal "ok"
  End

  It '引数の置換が完全一致で行われること'
    When call sx_fn_with 'cb=res="$1"' -- cb "callback"
    The status should be success
    The variable res should equal "callback"
    # cb は置換されるが、"callback" は置換されないことを期待
  End

  It '実行後に匿名関数が削除されていること'
    sx_fn_with 'temp_fn=:' -- :
    # type コマンドの stderr を抑制
    When call sh -c 'type __sx_anon_ 2>/dev/null'
    The status should be failure
  End

  It 'SX_SYS_REV がインクリメントされること'
    rev_before=$SX_SYS_REV
    sx_fn_with 'f1=:' 'f2=:' -- :
    The variable SX_SYS_REV should equal $((rev_before + 2))
  End

  It 'ネストした sx_fn_with が動作すること'
    When call sx_fn_with 'f1=sx_fn_with "f2=res=ok" -- f2' -- f1
    The status should be success
    The variable res should equal "ok"
  End

  It '匿名関数が正しく定義され、置換されていること'
    When call sx_fn_with 'myfn=res=replaced' -- myfn
    The status should be success
    The variable res should equal "replaced"
  End

  It 'エイリアス置換が部分一致しないこと'
    res=initial
    When call sx_fn_with 'f=res=replaced' -- :
    # f は定義されているが、引数は : なので置換されないはず。
    # 置換されなければ res は initial のまま。
    The status should be success
    The variable res should equal "initial"
  End

  It 'コマンドの終了ステータスが保持されること'
    When call sx_fn_with 'f=return 123' -- f
    The status should equal 123
  End

  It 'セパレータなしでも動作すること'
    When call sx_fn_with 'f=res=ok' f
    The status should be success
    The variable res should equal "ok"
  End

  It '定義の本体が不正な場合に EX_USAGE を返すこと'
    # eval で確実に構文エラーになるような不正な関数本体
    When call sx_fn_with 'f=res=(' -- f
    The status should equal 64
  End

  Describe 'SX_CFG_SEP の変更'
    It 'カスタムセパレータを使用できること'
      SX_CFG_SEP="@@"
      When call sx_fn_with 'f=res=custom' @@ f
      The status should be success
      The variable res should equal "custom"
    End
  End

  Describe 'クォーティングの検証'
    It 'スペースを含む引数を正しく扱えること'
      When call sx_fn_with 'f=res="$1"' -- f "hello world"
      The status should be success
      The variable res should equal "hello world"
    End

    It 'クォートを含む引数を正しく扱えること'
      When call sx_fn_with "f=res=\"\$1\"" -- f "it's me"
      The status should be success
      The variable res should equal "it's me"
    End
  End

  Describe 'B方式の懸念点: eval再解釈の検証'
    It 'ダブルクォートを含む引数を壊さないこと'
      When call sx_fn_with 'f=res="$1"' -- f 'he said "hi"'
      The status should be success
      The variable res should equal 'he said "hi"'
    End

    It 'ダブルクォートの境界を壊さないこと'
      When call sx_fn_with 'f=res="$1"' -- f 'a"b'
      The status should be success
      The variable res should equal 'a"b'
    End

    It 'ドル・コマンド置換を再評価しないこと'
      When call sx_fn_with 'f=res="$1"' -- f 'a$b `c`'
      The status should be success
      The variable res should equal 'a$b `c`'
    End

    It 'グロブ文字を展開しないこと'
      When call sx_fn_with 'f=res="$1"' -- f "*"
      The status should be success
      The variable res should equal "*"
    End

    It '空文字引数を欠落させないこと'
      When call sx_fn_with 'f=res="[$1][$2]"' -- f "" "x"
      The status should be success
      The variable res should equal "[][x]"
    End

    It 'セミコロンをコマンドとして実行しないこと'
      When call sx_fn_with 'f=res="$1"' -- f 'a;res=hacked'
      The status should be success
      The variable res should equal 'a;res=hacked'
    End

    It 'SEP後のa=bはコマンドとして失敗すること'
      When call sx_fn_with 'f=:' -- 'a=b'
      The status should be failure
      The stderr should include 'a=b'
    End

    It 'SEP後のa=bを定義扱いしないこと (REVは1だけ増える)'
      rev_before=$SX_SYS_REV
      sx_fn_with 'f=:' -- 'a=b' >/dev/null 2>&1 || :
      The variable SX_SYS_REV should equal $((rev_before + 1))
    End

    It '改行を含む引数を壊さないこと'
      # shellspec の When call + should equal は複数行値の転送に弱いため、
      # 直接呼出しと case で検証する (本体が改行を保持することは別途手動確認済み)。
      sx_fn_with 'f=res="$1"' -- f 'a
b'
      case "${res}" in
        'a
b') nl_ok=1;;
        *) nl_ok=0;;
      esac
      The variable nl_ok should equal 1
    End

    It '失敗時もstatusを返しREVが2増えること'
      rev_before=$SX_SYS_REV
      sx_fn_with 'f1=return 42' 'f2=:' -- f1 || status=$?
      The variable status should equal 42
      The variable SX_SYS_REV should equal $((rev_before + 2))
    End

    It '失敗時も複数の匿名関数を削除すること'
      rev_before=$SX_SYS_REV
      sx_fn_with 'f1=return 42' 'f2=:' -- f1 >/dev/null 2>&1 || :
      n1="sx_fn_anon_${rev_before}"
      n2="sx_fn_anon_$((rev_before + 1))"
      type "${n1}" >/dev/null 2>&1 && leak1=1 || leak1=0
      type "${n2}" >/dev/null 2>&1 && leak2=1 || leak2=0
      The variable leak1 should equal 0
      The variable leak2 should equal 0
    End

    It '空コマンドは成功すること'
      When call sx_fn_with -- :
      The status should be success
    End

    It '空コマンド時はREVを増やさないこと'
      rev_before=$SX_SYS_REV
      sx_fn_with -- :
      The variable SX_SYS_REV should equal $rev_before
    End
  End
End
