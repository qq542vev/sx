#!/bin/sh

eval "$(shellspec - -c) exit 1"

# shellcheck shell=sh

Describe 'sx_str_is_alnum'
  Include ./sx.sh

  It '英数字のみを含む文字列の場合、成功を返すこと'
    When call sx_str_is_alnum "abc123" "XYZ" "AbC99"
    The status should be success
  End

  It '単一の英数字の場合、成功を返すこと'
    When call sx_str_is_alnum "a"
    The status should be success
  End

  It 'アンダースコアが含まれる場合、失敗を返すこと'
    When call sx_str_is_alnum "abc_def"
    The status should be failure
  End

  It '区切り記号が含まれる場合、失敗を返すこと'
    When call sx_str_is_alnum "abc!def"
    The status should be failure
  End

  It '空文字列の場合、失敗を返すこと'
    When call sx_str_is_alnum ""
    The status should be failure
  End

  It 'スペースが含まれる場合、失敗を返すこと'
    When call sx_str_is_alnum " abc"
    The status should be failure
  End

  It '改行が含まれる場合、失敗を返すこと'
    When call sx_str_is_alnum "ab${SX_STR_LF}c"
    The status should be failure
  End

  It 'いずれかの引数が英数字でない場合、失敗を返すこと'
    When call sx_str_is_alnum "abc" "!@#" "123"
    The status should be failure
  End

  It '引数がない場合、成功を返すこと'
    When call sx_str_is_alnum
    The status should be success
  End

  It '非常に長い英数字文字列（1000桁）を検証できること'
    long_alnum=$(printf 'a1%.0s' $(seq 1 500))
    When call sx_str_is_alnum "${long_alnum}"
    The status should be success
  End

  It '多数の引数（10個以上）を一括検証できること'
    When call sx_str_is_alnum a b c 1 2 3 x y z 0
    The status should be success
  End
End
