#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_num_cmp_nat0'
  Include ./sx.sh

  It '多倍長の自然数を大小比較できること'
    When call sx_num_cmp_nat0 1000000000000000000 999999999999999999
    The status should equal 3
  End

  It '等しい自然数に 2 を返すこと'
    When call sx_num_cmp_nat0 0 0
    The status should equal 2
  End

  It '小さい自然数に 1 を返すこと'
    When call sx_num_cmp_nat0 1 10
    The status should equal 1
  End

  It '負数を引数不正として拒否すること'
    When call sx_num_cmp_nat0 -1 0
    The status should equal 64
  End

  It '不正な NUM_RANGE に 78 を返すこと'
    SX_CFG_NUM_RANGE=99
    When call sx_num_cmp_nat0 1 2
    The status should equal 78
  End
End
