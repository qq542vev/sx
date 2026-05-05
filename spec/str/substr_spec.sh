#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_str_substr()'
  Include ./sx.sh

  BeforeRun 'PATH=""'

  It '文字列の中間から部分文字列を抽出すること'
    When call sx_str_substr res "abcdef" 2 3
    The variable res should equal "cde"
  End

  It '文字列の先頭から抽出すること'
    When call sx_str_substr res "abcdef" 0 3
    The variable res should equal "abc"
  End

  It '長さが省略された場合に末尾まで抽出すること'
    When call sx_str_substr res "abcdef" 2
    The variable res should equal "cdef"
  End

  It '長さが残りを超える場合に末尾まで抽出すること'
    When call sx_str_substr res "abcdef" 4 10
    The variable res should equal "ef"
  End

  It 'オフセットが文字列長を超える場合に空文字列を返すこと'
    When call sx_str_substr res "abc" 5 2
    The variable res should equal ""
  End

  It '長さが0の場合に空文字列を返すこと'
    When call sx_str_substr res "abcdef" 2 0
    The variable res should equal ""
  End

  It 'メタ文字 (*, ?, [) を含む文字列を処理できること'
    When call sx_str_substr res "a*b?c[d" 1 3
    The variable res should equal "*b?"
  End

  It '空のソース文字列を処理できること'
    When call sx_str_substr res "" 0 5
    The variable res should equal ""
  End

  It '数値ではないオフセットに対してエラーを返すこと'
    When call sx_str_substr res "abc" "x"
    The status should equal 64
  End

  It '数値ではない長さに対してエラーを返すこと'
    When call sx_str_substr res "abc" 1 "y"
    The status should equal 64
  End

  It '読み取り専用の結果変数に対してエラーを返すこと'
    readonly MYRO_SUBSTR=1
    When call sx_str_substr MYRO_SUBSTR "abc" 0 1
    The status should equal 77
  End

  It '負のオフセットで末尾から抽出すること'
    When call sx_str_substr res "abcdef" -3
    The variable res should equal "def"
  End

  It '負のオフセットが全長を超える場合に先頭から抽出すること'
    When call sx_str_substr res "abcdef" -10
    The variable res should equal "abcdef"
  End

  It '負の長さで末尾の文字を除外すること'
    When call sx_str_substr res "abcdef" 0 -2
    The variable res should equal "abcd"
  End

  It '負のオフセットと負の長さの両方を処理できること'
    When call sx_str_substr res "abcdef" -4 -1
    The variable res should equal "cde"
  End

  It '負の長さですべての文字が除外される場合に空文字列を返すこと'
    When call sx_str_substr res "abc" 1 -5
    The variable res should equal ""
  End
End
