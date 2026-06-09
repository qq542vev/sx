#!/bin/sh

eval "$(shellspec - -c) exit 1"

# shellcheck shell=sh

Describe 'sx_str_is_lower'
  Include ./sx.sh

  It '小文字のみを含む文字列の場合、成功を返すこと'
    When call sx_str_is_lower "abc" "x" "xyz"
    The status should be success
  End

  It '単一の小文字の場合、成功を返すこと'
    When call sx_str_is_lower "a"
    The status should be success
  End

  It '大文字が含まれる場合、失敗を返すこと'
    When call sx_str_is_lower "aBc"
    The status should be failure
  End

  It '数字が含まれる場合、失敗を返すこと'
    When call sx_str_is_lower "ab0"
    The status should be failure
  End

  It '空文字列の場合、失敗を返すこと'
    When call sx_str_is_lower ""
    The status should be failure
  End

  It 'スペースが含まれる場合、失敗を返すこと'
    When call sx_str_is_lower " abc"
    The status should be failure
  End

  It '改行が含まれる場合、失敗を返すこと'
    When call sx_str_is_lower "ab${SX_STR_LF}c"
    The status should be failure
  End

  It 'いずれかの引数が小文字でない場合、失敗を返すこと'
    When call sx_str_is_lower "abc" "ABC" "xyz"
    The status should be failure
  End

  It '引数がない場合、成功を返すこと'
    When call sx_str_is_lower
    The status should be success
  End

  It '非常に長い小文字文字列（1000桁）を検証できること'
    long_lower=$(printf 'a%.0s' $(seq 1 1000))
    When call sx_str_is_lower "${long_lower}"
    The status should be success
  End

  It '多数の引数（10個以上）を一括検証できること'
    When call sx_str_is_lower a b c d e f g h i j
    The status should be success
  End
End
