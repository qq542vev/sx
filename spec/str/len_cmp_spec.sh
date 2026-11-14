#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_str_len_cmp'
  sxtest_load ./build/modules/sx_str_len_cmp.sh

  It '文字列1の方が短い場合に 1 を返すこと'
    When call sx_str_len_cmp "ab" "abc"
    The status should equal 1
  End

  It '長さが等しい場合に 2 を返すこと'
    When call sx_str_len_cmp "abc" "abc"
    The status should equal 2
  End

  It '文字列1の方が長い場合に 3 を返すこと'
    When call sx_str_len_cmp "abc" "ab"
    The status should equal 3
  End

  It '両方空文字列の場合に 2 を返すこと'
    When call sx_str_len_cmp "" ""
    The status should equal 2
  End

  It '文字列1が空で文字列2が非空の場合に 1 を返すこと'
    When call sx_str_len_cmp "" "abc"
    The status should equal 1
  End

  It '文字列1が非空で文字列2が空の場合に 3 を返すこと'
    When call sx_str_len_cmp "abc" ""
    The status should equal 3
  End

  It '特殊文字*を含む文字列の長さ比較ができること'
    When call sx_str_len_cmp "a*b" "a*b"
    The status should equal 2
  End
End
