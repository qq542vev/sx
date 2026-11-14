#!/bin/sh

eval "$(shellspec - -c) exit 1"

# shellcheck shell=sh

Describe 'sx_str_is_prefixed'
  sxtest_load ./build/modules/sx_str_is_prefixed.sh

  It 'すべての文字列が接頭辞で始まる場合、成功を返すこと'
    When call sx_str_is_prefixed "foo" "foobar" "foobaz"
    The status should be success
  End

  It 'いずれかが接頭辞で始まらない場合、失敗を返すこと'
    When call sx_str_is_prefixed "foo" "foobar" "barfoo"
    The status should be failure
  End

  It '接頭辞が空の場合、成功を返すこと'
    When call sx_str_is_prefixed "" "foo" "bar"
    The status should be success
  End

  It '文字列が 0 個の場合、成功を返すこと'
    When call sx_str_is_prefixed "foo"
    The status should be success
  End

  It '引数がない場合、成功を返すこと'
    When call sx_str_is_prefixed
    The status should be success
  End

  It '完全一致も成功を返すこと'
    When call sx_str_is_prefixed "foo" "foo"
    The status should be success
  End

  It '大文字小文字を区別すること'
    When call sx_str_is_prefixed "FOO" "foobar"
    The status should be failure
  End
End
