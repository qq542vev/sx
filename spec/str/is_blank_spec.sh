#!/bin/sh

eval "$(shellspec - -c) exit 1"

# shellcheck shell=sh

Describe 'sx_str_is_blank'
  Include ./sx.sh

  It '空白（スペース）のみの場合、成功を返すこと'
    When call sx_str_is_blank "   "
    The status should be success
  End

  It '空白（タブ）のみの場合、成功を返すこと'
    When call sx_str_is_blank "$(printf '\t')"
    The status should be success
  End

  It '空白（タブとスペースの混在）の場合、成功を返すこと'
    When call sx_str_is_blank "$(printf ' \t ')"
    The status should be success
  End

  It '複数の空白文字列の場合、成功を返すこと'
    When call sx_str_is_blank " " "$(printf '\t')"
    The status should be success
  End

  It '英字が含まれる場合、失敗を返すこと'
    When call sx_str_is_blank " a "
    The status should be failure
  End

  It '改行が含まれる場合、失敗を返すこと'
    When call sx_str_is_blank "$(printf '\n')"
    The status should be failure
  End

  It '空文字列の場合、失敗を返すこと'
    When call sx_str_is_blank ""
    The status should be failure
  End

  It 'いずれかの引数が空白でない場合、失敗を返すこと'
    When call sx_str_is_blank " " "a" "$(printf '\t')"
    The status should be failure
  End

  It '引数がない場合、成功を返すこと'
    When call sx_str_is_blank
    The status should be success
  End

  It '非常に長い空白文字列（1000桁）を検証できること'
    long_blank=$(printf ' %.0s' $(seq 1 1000))
    When call sx_str_is_blank "${long_blank}"
    The status should be success
  End

  It '多数の引数（10個以上）を一括検証できること'
    When call sx_str_is_blank " " " " " " " " " " " " " " " " " " " "
    The status should be success
  End
End
