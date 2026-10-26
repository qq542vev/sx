#!/bin/sh

eval "$(shellspec - -c) exit 1"

# shellcheck shell=sh

Describe 'sx_str_is_nonempty / __sx_str_is_nonempty'
  sxtest_load ./build/modules/sx_str_is_nonempty.sh

  Parameters
    sx_str_is_nonempty
    __sx_str_is_nonempty
  End

  It 'すべての引数が空でない場合、0を返すこと'
    When call "$1" 'abc' '0' '日本語'
    The status should equal 0
  End

  It '引数がない場合、0を返すこと'
    When call "$1"
    The status should equal 0
  End

  It '空白や改行だけの文字列も空でないと判定すること'
    When call "$1" ' ' '
'
    The status should equal 0
  End

  It 'シェルの特殊文字も文字列として判定すること'
    When call "$1" '*?[]' '$(exit 1)' 'a b' ':::'
    The status should equal 0
  End

  It '空文字列の場合、1を返すこと'
    When call "$1" ''
    The status should equal 1
  End

  It '先頭の引数が空文字列の場合、1を返すこと'
    When call "$1" '' 'abc' 'def'
    The status should equal 1
  End

  It '途中の引数が空文字列の場合、1を返すこと'
    When call "$1" 'abc' '' 'def'
    The status should equal 1
  End

  It '最後の引数が空文字列の場合、1を返すこと'
    When call "$1" 'abc' 'def' ''
    The status should equal 1
  End
End
