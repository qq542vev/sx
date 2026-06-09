#!/bin/sh

eval "$(shellspec - -c) exit 1"

# shellcheck shell=sh

Describe 'sx_str_is_cntrl'
  Include ./sx.sh

  It '単一の制御文字の場合、成功を返すこと'
    When call sx_str_is_cntrl "$(printf '\001')"
    The status should be success
  End

  It '複数の制御文字のみの場合、成功を返すこと'
    When call sx_str_is_cntrl "$(printf '\001\002\003')"
    The status should be success
  End

  It 'DEL（0x7F）の場合、成功を返すこと'
    When call sx_str_is_cntrl "$(printf '\177')"
    The status should be success
  End

  It '複数の有効な制御文字列の場合、成功を返すこと'
    When call sx_str_is_cntrl "$(printf '\001')" "$(printf '\007')" "$(printf '\033')"
    The status should be success
  End

  It '英字が含まれる場合、失敗を返すこと'
    When call sx_str_is_cntrl "$(printf '\001a')"
    The status should be failure
  End

  It 'スペースが含まれる場合、失敗を返すこと'
    When call sx_str_is_cntrl "$(printf '\001 ')"
    The status should be failure
  End

  It '空文字列の場合、失敗を返すこと'
    When call sx_str_is_cntrl ""
    The status should be failure
  End

  It 'いずれかの引数が制御文字でない場合、失敗を返すこと'
    When call sx_str_is_cntrl "$(printf '\001')" "a" "$(printf '\002')"
    The status should be failure
  End

  It '引数がない場合、成功を返すこと'
    When call sx_str_is_cntrl
    The status should be success
  End

  It '非常に長い制御文字列（1000桁）を検証できること'
    long_cntrl=$(printf '\001%.0s' $(seq 1 1000))
    When call sx_str_is_cntrl "${long_cntrl}"
    The status should be success
  End
End
