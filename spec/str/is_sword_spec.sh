#!/bin/sh

eval "$(shellspec - -c) exit 1"

# shellcheck shell=sh

Describe 'sx_str_is_sword'
  sxtest_load ./build/modules/sx_str_is_sword.sh

  It 'すべての英字とアンダースコアを受理すること'
    When call sx_str_is_sword 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_'
    The status should be success
  End

  It 'アンダースコアのみを受理すること'
    When call sx_str_is_sword '_'
    The status should be success
  End

  It '複数の有効な文字列を受理すること'
    When call sx_str_is_sword 'abc' '_ABC' 'a_b_'
    The status should be success
  End

  It '数字が含まれる場合は1を返すこと'
    When call sx_str_is_sword 'abc_123'
    The status should equal 1
  End

  It '数字のみの場合は1を返すこと'
    When call sx_str_is_sword '0123456789'
    The status should equal 1
  End

  It '記号が含まれる場合は1を返すこと'
    When call sx_str_is_sword 'abc-def'
    The status should equal 1
  End

  It '空白が含まれる場合は1を返すこと'
    When call sx_str_is_sword 'abc def'
    The status should equal 1
  End

  It 'ASCII外の英字は1を返すこと'
    When call sx_str_is_sword 'é'
    The status should equal 1
  End

  It '空文字列の場合は1を返すこと'
    When call sx_str_is_sword ''
    The status should equal 1
  End

  It '後続の引数に数字が含まれる場合は1を返すこと'
    When call sx_str_is_sword 'abc' 'def1' '_ABC'
    The status should equal 1
  End

  It '後続の引数が空文字列の場合は1を返すこと'
    When call sx_str_is_sword 'abc' '' '_ABC'
    The status should equal 1
  End

  It '引数なしの場合は成功を返すこと'
    When call sx_str_is_sword
    The status should be success
  End
End
