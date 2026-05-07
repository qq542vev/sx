#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_num_ge'
  Include ./sx.sh

  It '数値が非増加順（降順または等しい）である場合に成功を返すこと'
    When call sx_num_ge 3 2 2 1
    The status should be success
  End

  It '各基数が混在していても正しく比較できること'
    When call sx_num_ge "10" "012" "0x9" "8" "07"
    The status should be success
  End

  It '数値が非増加順でない場合に失敗を返すこと'
    When call sx_num_ge 2 3 1
    The status should be failure
  End

  It '非数値の入力が含まれる場合に失敗を返すこと'
    When call sx_num_ge 1 "a"
    The status should be failure
  End

  It '1つの引数に対して成功を返すこと'
    When call sx_num_ge "0x1"
    The status should be success
  End

  It '引数がない場合に成功を返すこと'
    When call sx_num_ge
    The status should be success
  End
End
