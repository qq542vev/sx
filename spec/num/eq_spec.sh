#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_num_eq'
  Include ./sx.sh

  It 'すべての数値が等しい場合に成功を返すこと'
    When call sx_num_eq 1 1 1
    The status should be success
  End

  It '各基数が混在していても数値として等しければ成功を返すこと'
    When call sx_num_eq 10 "012" "0xA"
    The status should be success
  End

  It '等しくない数値が含まれる場合に失敗を返すこと'
    When call sx_num_eq 1 1 2
    The status should be failure
  End

  It '非数値の入力が含まれる場合に失敗を返すこと'
    When call sx_num_eq 1 "a"
    The status should be failure
  End

  It '1つの引数に対して成功を返すこと'
    When call sx_num_eq "0x1"
    The status should be success
  End

  It '引数がない場合に成功を返すこと'
    When call sx_num_eq
    The status should be success
  End
End
