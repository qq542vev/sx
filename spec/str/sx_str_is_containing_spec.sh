#!/bin/sh

eval "$(shellspec - -c) exit 1"

# shellcheck shell=sh

Describe 'sx_str_is_containing'
  sxtest_load ./build/modules/sx_str_is_containing.sh

  It 'すべての文字列が部分文字列を含む場合、成功を返すこと'
    When call sx_str_is_containing "foo" "foobar" "foobaz"
    The status should be success
  End

  It 'いずれかが部分文字列を含まない場合、失敗を返すこと'
    When call sx_str_is_containing "foo" "foobar" "barbaz"
    The status should be failure
  End

  It '部分文字列が空の場合、成功を返すこと'
    When call sx_str_is_containing "" "foo" "bar"
    The status should be success
  End

  It '文字列が 0 個の場合、成功を返すこと'
    When call sx_str_is_containing "foo"
    The status should be success
  End

  It '引数がない場合、成功を返すこと'
    When call sx_str_is_containing
    The status should be success
  End

  It '完全一致も成功を返すこと'
    When call sx_str_is_containing "foo" "foo"
    The status should be success
  End

  It '中間一致を検出すること'
    When call sx_str_is_containing "bar" "foobar"
    The status should be success
  End

  It '大文字小文字を区別すること'
    When call sx_str_is_containing "FOO" "foobar"
    The status should be failure
  End
End
