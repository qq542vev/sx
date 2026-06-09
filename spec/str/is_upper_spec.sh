#!/bin/sh

eval "$(shellspec - -c) exit 1"

# shellcheck shell=sh

Describe 'sx_str_is_upper'
  Include ./sx.sh

  It '大文字のみを含む文字列の場合、成功を返すこと'
    When call sx_str_is_upper "ABC" "X" "XYZ"
    The status should be success
  End

  It '単一の大文字の場合、成功を返すこと'
    When call sx_str_is_upper "A"
    The status should be success
  End

  It '小文字が含まれる場合、失敗を返すこと'
    When call sx_str_is_upper "Abc"
    The status should be failure
  End

  It '数字が含まれる場合、失敗を返すこと'
    When call sx_str_is_upper "AB0"
    The status should be failure
  End

  It '空文字列の場合、失敗を返すこと'
    When call sx_str_is_upper ""
    The status should be failure
  End

  It 'スペースが含まれる場合、失敗を返すこと'
    When call sx_str_is_upper " ABC"
    The status should be failure
  End

  It '改行が含まれる場合、失敗を返すこと'
    When call sx_str_is_upper "AB${SX_STR_LF}C"
    The status should be failure
  End

  It 'いずれかの引数が大文字でない場合、失敗を返すこと'
    When call sx_str_is_upper "ABC" "abc" "XYZ"
    The status should be failure
  End

  It '引数がない場合、成功を返すこと'
    When call sx_str_is_upper
    The status should be success
  End

  It '非常に長い大文字文字列（1000桁）を検証できること'
    long_upper=$(printf 'A%.0s' $(seq 1 1000))
    When call sx_str_is_upper "${long_upper}"
    The status should be success
  End

  It '多数の引数（10個以上）を一括検証できること'
    When call sx_str_is_upper A B C D E F G H I J
    The status should be success
  End
End
