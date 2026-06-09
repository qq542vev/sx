#!/bin/sh

eval "$(shellspec - -c) exit 1"

# shellcheck shell=sh

Describe 'sx_str_is_hex'
  Include ./sx.sh

  It '有効な小文字の 16 進数文字列の場合、成功を返すこと'
    When call sx_str_is_hex "0123456789abcdef"
    The status should be success
  End

  It '有効な大文字の 16 進数文字列の場合、成功を返すこと'
    When call sx_str_is_hex "ABCDEF"
    The status should be success
  End

  It '大文字小文字が混在した有効な 16 進数文字列の場合、成功を返すこと'
    When call sx_str_is_hex "aBcD09"
    The status should be success
  End

  It '複数の有効な 16 進数文字列の場合、成功を返すこと'
    When call sx_str_is_hex "123" "abc" "DEF"
    The status should be success
  End

  It '空文字列の場合、失敗を返すこと'
    When call sx_str_is_hex ""
    The status should be failure
  End

  It '16 進数以外の文字（0xなど）が含まれる場合、失敗を返すこと'
    When call sx_str_is_hex "0x123"
    The status should be failure
  End

  It 'f を超える文字が含まれる場合、失敗を返すこと'
    When call sx_str_is_hex "gh"
    The status should be failure
  End

  It 'スペースが含まれる場合、失敗を返すこと'
    When call sx_str_is_hex " abc"
    The status should be failure
  End

  It '改行が含まれる場合、失敗を返すこと'
    When call sx_str_is_hex "ab${SX_STR_LF}cd"
    The status should be failure
  End

  It 'いずれかの引数が 16 進数でない場合、失敗を返すこと'
    When call sx_str_is_hex "abc" "xyz" "123"
    The status should be failure
  End

  It '引数がない場合、成功を返すこと'
    When call sx_str_is_hex
    The status should be success
  End

  It '非常に長い16進数文字列（1000桁）を検証できること'
    long_hex=$(printf 'a%.0s' $(seq 1 1000))
    When call sx_str_is_hex "${long_hex}"
    The status should be success
  End

  It '多数の引数（10個以上）を一括検証できること'
    When call sx_str_is_hex a b c d e f 0 1 2 3
    The status should be success
  End
End
