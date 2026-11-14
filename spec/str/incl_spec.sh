#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_str_incl'
  sxtest_load ./build/modules/sx_str_incl.sh

  It '等しい場合に 2 を返すこと'
    When call sx_str_incl "abc" "abc"
    The status should equal 2
  End

  It '文字列1が文字列2に含まれる場合に 1 を返すこと'
    When call sx_str_incl "bc" "abc"
    The status should equal 1
  End

  It '文字列1が文字列2を含む場合に 3 を返すこと'
    When call sx_str_incl "abc" "bc"
    The status should equal 3
  End

  It '互いに素の場合に 4 を返すこと'
    When call sx_str_incl "abc" "def"
    The status should equal 4
  End

  It '両方空文字列の場合に 2 を返すこと'
    When call sx_str_incl "" ""
    The status should equal 2
  End

  It '文字列1が空で文字列2が非空の場合に 1 を返すこと'
    When call sx_str_incl "" "abc"
    The status should equal 1
  End

  It '文字列1が非空で文字列2が空の場合に 3 を返すこと'
    When call sx_str_incl "abc" ""
    The status should equal 3
  End

  It '特殊文字*を含む文字列の等値判定ができること'
    When call sx_str_incl "a*b" "a*b"
    The status should equal 2
  End

End
