#!/bin/sh

eval "$(shellspec - -c) exit 1"

# shellcheck shell=sh

Describe 'sx_str_is_space'
  Include ./sx.sh

  It 'スペースのみの場合、成功を返すこと'
    When call sx_str_is_space "   "
    The status should be success
  End

  It 'タブのみの場合、成功を返すこと'
    When call sx_str_is_space "$(printf '\t')"
    The status should be success
  End

  It '改行のみの場合、成功を返すこと'
    When call sx_str_is_space "$(printf '\n ')"
    The status should be success
  End

  It '垂直タブのみの場合、成功を返すこと'
    When call sx_str_is_space "$(printf '\v')"
    The status should be success
  End

  It '複数の空白文字（各種類）が混在する場合、成功を返すこと'
    When call sx_str_is_space "$(printf ' \t\n\v\f\r ')"
    The status should be success
  End

  It '英字が含まれる場合、失敗を返すこと'
    When call sx_str_is_space " a "
    The status should be failure
  End

  It '制御文字（空白以外）が含まれる場合、失敗を返すこと'
    When call sx_str_is_space "$(printf '\001')"
    The status should be failure
  End

  It '空文字列の場合、失敗を返すこと'
    When call sx_str_is_space ""
    The status should be failure
  End

  It 'いずれかの引数が空白でない場合、失敗を返すこと'
    When call sx_str_is_space " " "a" "$(printf '\n')"
    The status should be failure
  End

  It '引数がない場合、成功を返すこと'
    When call sx_str_is_space
    The status should be success
  End

  It '非常に長い空白文字列（1000桁）を検証できること'
    long_space=$(printf ' %.0s' $(seq 1 1000))
    When call sx_str_is_space "${long_space}"
    The status should be success
  End
End
