#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_str_eq'
  Include ./sx.sh
  It 'すべての引数が等しい場合に成功を返すこと'
    When call sx_str_eq "a" "a" "a"
    The status should be success
  End

  It 'いずれかの引数が異なる場合に失敗を返すこと'
    When call sx_str_eq "a" "a" "b"
    The status should be failure
  End

  It '引数が1つの場合に成功を返すこと'
    When call sx_str_eq "a"
    The status should be success
  End

  It '引数がない場合に成功を返すこと'
    When call sx_str_eq
    The status should be success
  End

  It '特殊文字*を含む文字列が等しい場合に成功を返すこと'
    When call sx_str_eq "a*b" "a*b"
    The status should be success
  End

  It '特殊文字?を含む文字列が等しい場合に成功を返すこと'
    When call sx_str_eq "a?b" "a?b"
    The status should be success
  End

  It '5つ以上の引数で連鎖等値比較が成功すること'
    When call sx_str_eq "x" "x" "x" "x" "x"
    The status should be success
  End

  It 'すべての引数が空文字列の場合に成功を返すこと'
    When call sx_str_eq "" "" ""
    The status should be success
  End

  It '空文字列と非空文字列が混在した場合に失敗を返すこと'
    When call sx_str_eq "" "a"
    The status should be failure
  End

  It 'タブ文字を含む文字列の等値比較ができること'
    tab=$(printf '\t')
    When call sx_str_eq "${tab}a" "${tab}a"
    The status should be success
  End
End
