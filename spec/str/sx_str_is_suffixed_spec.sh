#!/bin/sh

eval "$(shellspec - -c) exit 1"

# shellcheck shell=sh

Describe 'sx_str_is_suffixed'
  sxtest_load ./build/modules/sx_str_is_suffixed.sh

  It 'すべての文字列が接尾辞で終わる場合、成功を返すこと'
    When call sx_str_is_suffixed "bar" "foobar" "foobazbar"
    The status should be success
  End

  It 'いずれかが接尾辞で終わらない場合、失敗を返すこと'
    When call sx_str_is_suffixed "bar" "foobar" "barfoo"
    The status should be failure
  End

  It '接尾辞が空の場合、成功を返すこと'
    When call sx_str_is_suffixed "" "foo" "bar"
    The status should be success
  End

  It '文字列が 0 個の場合、成功を返すこと'
    When call sx_str_is_suffixed "bar"
    The status should be success
  End

  It '引数がない場合、成功を返すこと'
    When call sx_str_is_suffixed
    The status should be success
  End

  It '完全一致も成功を返すこと'
    When call sx_str_is_suffixed "foo" "foo"
    The status should be success
  End

  It '大文字小文字を区別すること'
    When call sx_str_is_suffixed "FOO" "foobar"
    The status should be failure
  End
End
