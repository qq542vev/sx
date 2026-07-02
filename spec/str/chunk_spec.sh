#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe "sx_str_chunk"
  Include ./sx.sh

  It "正の長さで文字列を前方から分割すること"
    When call sx_str_chunk res "abcde" 2
    The status should be success
    The variable res should equal "'ab' 'cd' 'e'"
  End

  It "負の長さで文字列を後方から分割すること"
    When call sx_str_chunk res "abcde" -2
    The status should be success
    The variable res should equal "'a' 'bc' 'de'"
  End

  It "前方分割の回数制限に従うこと"
    When call sx_str_chunk res "abcde" 2 1
    The status should be success
    The variable res should equal "'ab' 'cde'"
  End

  It "後方分割の回数制限に従うこと"
    When call sx_str_chunk res "abcde" -2 1
    The status should be success
    The variable res should equal "'abc' 'de'"
  End

  It "文字列より長い分割長を処理できること"
    When call sx_str_chunk res "abc" 10
    The status should be success
    The variable res should equal "'abc'"
  End

  It "文字列より長い負の分割長を処理できること"
    When call sx_str_chunk res "abc" -10
    The status should be success
    The variable res should equal "'abc'"
  End

  It "空文字列を処理できること"
    When call sx_str_chunk res "" 2
    The status should be success
    The variable res should equal ""
  End

  It "特殊文字を安全に処理できること"
    When call sx_str_chunk res "a*b? c'd" 2
    The status should be success
    The variable res should equal "'a*' 'b?' ' c' ''\''d'"
  End

  It "分割長が0の場合に EX_USAGE (64) を返すこと"
    When call sx_str_chunk res "abc" 0
    The status should equal 64
  End

  It "分割長が数値ではない場合に EX_USAGE (64) を返すこと"
    When call sx_str_chunk res "abc" "invalid"
    The status should equal 64
  End

  It "バインドチェーンを用いて前方から分配代入できること"
    When call sx_str_chunk "v1:v2:rest" "abcde" 2
    The status should be success
    The variable v1 should equal "ab"
    The variable v2 should equal "cd"
    The variable rest should equal "'e'"
  End

  It "バインドチェーンを用いて後方から分配代入できること"
    When call sx_str_chunk "v1:v2:rest" "abcde" -2
    The status should be success
    The variable v1 should equal "a"
    The variable v2 should equal "bc"
    The variable rest should equal "'de'"
  End

  It "シェルのメタ文字を安全に（展開せずに）処理できること"
    When call sx_str_chunk "v1:v2:rest" ' $(echo BUG) $HOME `date` ' 7
    The status should be success
    The variable v1 should equal ' $(echo'
    The variable v2 should equal ' BUG) $'
    The variable rest should equal "'HOME \`d' 'ate\` '"
  End

  It "バインドチェーン末尾がコロンの場合（a:b:）に正しく代入されること"
    When call sx_str_chunk "v1:v2:" "abcde" 1
    The status should be success
    The variable v1 should equal "a"
    The variable v2 should equal "b"
  End

  It "コマンド置換を含む文字列が実行（二重評価）されないこと"
    When call sx_str_chunk "v1" '$(echo INJECTION)' 20
    The status should be success
    The variable v1 should equal "'\$(echo INJECTION)'"
  End

  It "a:b: 形式で巨大な文字列を高速に処理できること"
    # 10,000文字の文字列を生成
    long_str="aaaaaaaaaa" # 10
    long_str="${long_str}${long_str}${long_str}${long_str}${long_str}${long_str}${long_str}${long_str}${long_str}${long_str}" # 100
    long_str="${long_str}${long_str}${long_str}${long_str}${long_str}${long_str}${long_str}${long_str}${long_str}${long_str}" # 1,000
    long_str="${long_str}${long_str}${long_str}${long_str}${long_str}${long_str}${long_str}${long_str}${long_str}${long_str}" # 10,000
    
    When call sx_str_chunk "v1:v2:" "$long_str" 1
    The status should be success
    The variable v1 should equal "a"
    The variable v2 should equal "a"
  End

  Describe "組み合わせテスト: 前方分割"
    It "前方分割: limitなし + バインドチェーン"
      When call sx_str_chunk "v1:v2:rest" "abcde" 2
      The variable v1 should equal "ab"
      The variable v2 should equal "cd"
      The variable rest should equal "'e'"
    End

    It "前方分割: limitあり + バインドチェーン"
      When call sx_str_chunk "v1:v2:rest" "abcdefgh" 2 2
      # 1:ab, 2:cd -> limit到達 -> 残り:efgh
      The variable v1 should equal "ab"
      The variable v2 should equal "cd"
      The variable v3 should be undefined
      The variable rest should equal "'efgh'"
    End

    It "前方分割: limitあり + 早期終了形式"
      When call sx_str_chunk "v1:v2:" "abcdefgh" 2 1
      # 1:ab -> limit到達 -> 残り:cdefgh -> v2に代入
      The variable v1 should equal "ab"
      The variable v2 should equal "cdefgh"
    End
  End

  Describe "組み合わせテスト: 後方分割"
    It "後方分割: limitなし + バインドチェーン"
      When call sx_str_chunk "v1:v2:rest" "abcde" -2
      The variable v1 should equal "a"
      The variable v2 should equal "bc"
      The variable rest should equal "'de'"
    End

    It "後方分割: limitあり + バインドチェーン"
      When call sx_str_chunk "v1:v2:rest" "abcdefgh" -2 2
      # 後方から2回: 1:gh, 2:ef -> 残り:abcd
      # 出現順に並ぶので: v1=abcd, v2=ef, rest='gh'
      The variable v1 should equal "abcd"
      The variable v2 should equal "ef"
      The variable rest should equal "'gh'"
    End

    It "後方分割: limitあり + 早期終了形式"
      When call sx_str_chunk "v1:v2:" "abcdefgh" -2 1
      # 後方から1回: 1:gh -> 残り:abcdef
      # v1=abcdef, v2=gh
      The variable v1 should equal "abcdef"
      The variable v2 should equal "gh"
    End
  End

  It "読み取り専用変数に対して EX_NOPERM (77) を返すこと"
    readonly ro_var_chunk=fixed
    When call sx_str_chunk ro_var_chunk "abc" 2
    The status should equal 77
  End

  It "SKIP_SHORT で短い残余をスキップすること"
    When call sx_str_chunk res "abcde" 2 '' "${SX_STR_CHUNK_SKIP_SHORT}"
    The variable res should equal "'ab' 'cd'"
  End

  It "SKIP_LONG で長い残余をスキップすること（lim 到達時）"
    When call sx_str_chunk res "abcdefgh" 2 2 "${SX_STR_CHUNK_SKIP_LONG}"
    The variable res should equal "'ab' 'cd'"
  End

  It "両フラグで残余 == size のみ許可すること"
    When call sx_str_chunk res "abcdef" 2 '' "$((SX_STR_CHUNK_SKIP_SHORT + SX_STR_CHUNK_SKIP_LONG))"
    The variable res should equal "'ab' 'cd' 'ef'"
  End

  It "SKIP_SHORT は後方分割でも動作すること"
    When call sx_str_chunk res "abcde" -2 '' "${SX_STR_CHUNK_SKIP_SHORT}"
    The variable res should equal "'bc' 'de'"
  End

  It "SKIP_SHORT で割り切れる場合は全チャンク含まれること"
    When call sx_str_chunk res "abcdef" 2 '' "${SX_STR_CHUNK_SKIP_SHORT}"
    The variable res should equal "'ab' 'cd' 'ef'"
  End

  It "SKIP_SHORT + 早期終了チェーンで不完全チャンクをスキップすること"
    When call sx_str_chunk "v1:v2:" "abcde" 2 '' "${SX_STR_CHUNK_SKIP_SHORT}"
    The variable v1 should equal "ab"
    The variable v2 should equal "cd"
  End

  Describe "サイクル interval"
    It "2:3 で前方サイクル分割できること"
      When call sx_str_chunk res "abcdefghij" "2:3"
      The status should be success
      The variable res should equal "'ab' 'cde' 'fg' 'hij'"
    End

    It "1:2:3 で前方3値サイクルできること"
      When call sx_str_chunk res "abcdef" "1:2:3"
      The status should be success
      The variable res should equal "'a' 'bc' 'def'"
    End

    It "2:-3:4 で前方・後方混合サイクルできること"
      When call sx_str_chunk res "abcdefghij" "2:-3:4"
      The status should be success
      The variable res should equal "'ab' 'cdef' 'g' 'hij'"
    End

    It "-2:-4:3 で後方・前方混合サイクルできること"
      When call sx_str_chunk res "abcdefghij" "-2:-4:3"
      The status should be success
      The variable res should equal "'abc' 'd' 'efgh' 'ij'"
    End

    It "-2:-3 で全後方サイクルできること"
      When call sx_str_chunk res "abcdefghij" "-2:-3"
      The status should be success
      The variable res should equal "'abc' 'de' 'fgh' 'ij'"
    End

    It "単一値のサイクルが従来の単一値と同等であること"
      When call sx_str_chunk res "abcde" "2"
      The status should be success
      The variable res should equal "'ab' 'cd' 'e'"
    End

    It "SKIP_SHORT でサイクルの残余をスキップできること"
      When call sx_str_chunk res "abcdefghij" "2:-3:4" '' "${SX_STR_CHUNK_SKIP_SHORT}"
      The status should be success
      The variable res should equal "'ab' 'cdef' 'hij'"
    End

    It "SKIP_LONG でlimit到達時のサイクル残余をスキップできること"
      When call sx_str_chunk res "abcdefghij" "2:-3:4" 2 "${SX_STR_CHUNK_SKIP_LONG}"
      The status should be success
      The variable res should equal "'ab' 'hij'"
    End

    It "limit 1 でサイクルが1回で停止すること"
      When call sx_str_chunk res "abcdefghij" "2:-3:4" 1
      The status should be success
      The variable res should equal "'ab' 'cdefghij'"
    End

    It "limit 2 でサイクルが2回で停止すること"
      When call sx_str_chunk res "abcdefghij" "2:-3:4" 2
      The status should be success
      The variable res should equal "'ab' 'cdefg' 'hij'"
    End

    It "バインドチェーンでサイクルを分配代入できること"
      When call sx_str_chunk "v1:v2:rest" "abcdefghij" "2:-3:4"
      The status should be success
      The variable v1 should equal "ab"
      The variable v2 should equal "cdef"
      The variable rest should equal "'g' 'hij'"
    End

    It "バインドチェーン + 早期終了でサイクルを途中停止できること"
      When call sx_str_chunk "v1:v2:" "abcdefghij" "2:-3:4"
      The status should be success
      The variable v1 should equal "ab"
      The variable v2 should equal "cdef"
    End

    It "バインドチェーン + SKIP_SHORT でサイクルの残余をスキップできること"
      When call sx_str_chunk "v1:v2:rest" "abcdefghij" "2:-3:4" '' "${SX_STR_CHUNK_SKIP_SHORT}"
      The status should be success
      The variable v1 should equal "ab"
      The variable v2 should equal "cdef"
      The variable rest should equal "'hij'"
    End

    It "文字列より大きいサイクル値は全体を1チャンクとして扱うこと"
      When call sx_str_chunk res "a" "2:-3:4"
      The status should be success
      The variable res should equal "'a'"
    End

    It "空文字列にサイクルを適用しても空文字列を返すこと"
      When call sx_str_chunk res "" "2:-3:4"
      The status should be success
      The variable res should equal ""
    End

    It "割り切れるサイクルで残余が出ないこと"
      When call sx_str_chunk res "abcde" "2:3"
      The status should be success
      The variable res should equal "'ab' 'cde'"
    End

    It "サイクル内に0を含むと EX_USAGE を返すこと"
      When call sx_str_chunk res "abc" "2:0:3"
      The status should equal 64
    End

    It "サイクル内に不正文字を含むと EX_USAGE を返すこと"
      When call sx_str_chunk res "abc" "2:a:3"
      The status should equal 64
    End

    It "limit 0 でサイクルは全文字列を1チャンクとして返すこと"
      When call sx_str_chunk res "abcdefghij" "2:-3:4" 0
      The status should be success
      The variable res should equal "'abcdefghij'"
    End

    It "特殊文字を含む文字列をサイクルで安全に処理できること"
      When call sx_str_chunk res "a*b? c'd" "2:-3:4"
      The status should be success
      The variable res should equal "'a*' 'b? ' 'c'\''d'"
    End

    It "2:3:4 で SKIP_SHORT + SKIP_LONG 両フラグが exact fit で正しく動作すること"
      When call sx_str_chunk res "abcdefghi" "2:3:4" '' "$((SX_STR_CHUNK_SKIP_SHORT + SX_STR_CHUNK_SKIP_LONG))"
      The status should be success
      The variable res should equal "'ab' 'cde' 'fghi'"
    End
  End

  Describe "互換性: 従来の単一intervalが変わらず動作すること"
    It "前方分割: 既存テストと同じ結果"
      When call sx_str_chunk res "abcde" 2
      The status should be success
      The variable res should equal "'ab' 'cd' 'e'"
    End

    It "後方分割: 既存テストと同じ結果"
      When call sx_str_chunk res "abcde" -2
      The status should be success
      The variable res should equal "'a' 'bc' 'de'"
    End
  End
End
