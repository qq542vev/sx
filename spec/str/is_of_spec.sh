#!/bin/sh

eval "$(shellspec - -c) exit 1"

# shellcheck shell=sh

Describe 'sx_str_is_of'
  Include ./sx.sh

  It 'すべての引数が指定された文字集合のみを含む場合、成功を返すこと'
    When call sx_str_is_of "abc" "a" "ab" "abc" "cba"
    The status should be success
  End

  It '文字集合に含まれない文字がある場合、失敗を返すこと'
    When call sx_str_is_of "abc" "abcd"
    The status should be failure
  End

  It 'いずれかの引数が空文字列の場合、失敗を返すこと'
    When call sx_str_is_of "abc" "a" "" "c"
    The status should be failure
  End

  It '文字集合以外の文字が含まれる引数が混在する場合、失敗を返すこと'
    When call sx_str_is_of "abc" "a" "ax" "c"
    The status should be failure
  End

  It '引数（文字列）がない場合、成功を返すこと'
    When call sx_str_is_of "abc"
    The status should be success
  End

  It '文字集合に特殊文字（]や-など）が含まれていても正しく機能すること'
    When call sx_str_is_of "[]-" "]" "[" "-" "][" "---"
    The status should be success
  End

  It '補集合の判定が正しく機能すること（特殊文字を含む場合）'
    When call sx_str_is_of "[]-" "a"
    The status should be failure
  End
End
