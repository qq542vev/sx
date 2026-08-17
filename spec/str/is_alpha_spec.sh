#!/bin/sh

eval "$(shellspec - -c) exit 1"

# shellcheck shell=sh

Describe 'sx_str_is_alpha'
  Include ./sx.sh

  It '英字のみを含む文字列の場合、成功を返すこと'
    When call sx_str_is_alpha "abc" "XYZ" "AbC"
    The status should be success
  End

  It '単一の英字の場合、成功を返すこと'
    When call sx_str_is_alpha "a"
    The status should be success
  End

  It '数字が含まれる場合、失敗を返すこと'
    When call sx_str_is_alpha "abc123"
    The status should be failure
  End

  It 'アンダースコアが含まれる場合、失敗を返すこと'
    When call sx_str_is_alpha "abc_def"
    The status should be failure
  End

  It '空文字列の場合、失敗を返すこと'
    When call sx_str_is_alpha ""
    The status should be failure
  End

  It 'スペースが含まれる場合、失敗を返すこと'
    When call sx_str_is_alpha " abc"
    The status should be failure
  End

  It '改行が含まれる場合、失敗を返すこと'
    When call sx_str_is_alpha "ab${SX_STR_LF}c"
    The status should be failure
  End

  It 'いずれかの引数が英字でない場合、失敗を返すこと'
    When call sx_str_is_alpha "abc" "123" "XYZ"
    The status should be failure
  End

  It '引数がない場合、成功を返すこと'
    When call sx_str_is_alpha
    The status should be success
  End

  It '非常に長い英字文字列（1000桁）を検証できること'
    long_alpha=$(printf 'a%.0s' $(seq 1 1000))
    When call sx_str_is_alpha "${long_alpha}"
    The status should be success
  End

  It '多数の引数（10個以上）を一括検証できること'
    When call sx_str_is_alpha a b c d e f g h i j
    The status should be success
  End
End
