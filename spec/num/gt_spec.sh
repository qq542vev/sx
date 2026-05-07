#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_num_gt'
  Include ./sx.sh

  It '数値が厳密に減少順（降順）である場合に成功を返すこと'
    When call sx_num_gt 3 2 1
    The status should be success
  End

  It '各基数が混在していても正しく比較できること'
    When call sx_num_gt "012" "9" "0x8" "7" "06"
    The status should be success
  End


  It '数値が厳密に減少順でない場合に失敗を返すこと'
    When call sx_num_gt 3 2 2 1
    The status should be failure
  End

  It '非数値の入力が含まれる場合に失敗を返すこと'
    When call sx_num_gt "a" 1
    The status should be failure
  End

  It '1つの引数に対して成功を返すこと'
    When call sx_num_gt "010"
    The status should be success
  End

  It '引数がない場合に成功を返すこと'
    When call sx_num_gt
    The status should be success
  End
End
