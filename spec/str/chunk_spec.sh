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

  It "読み取り専用変数に対して EX_NOPERM (77) を返すこと"
    readonly ro_var_chunk=fixed
    When call sx_str_chunk ro_var_chunk "abc" 2
    The status should equal 77
  End
End
