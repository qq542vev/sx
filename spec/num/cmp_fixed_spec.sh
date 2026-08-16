#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_num_cmp_fixed'
  Include ./sx.sh

  It 'LHS < RHS の場合に 1 を返すこと (整数)'
    When call sx_num_cmp_fixed 10 20
    The status should equal 1
  End

  It 'LHS == RHS の場合に 2 を返すこと (整数)'
    When call sx_num_cmp_fixed 15 15
    The status should equal 2
  End

  It 'LHS > RHS の場合に 3 を返すこと (整数)'
    When call sx_num_cmp_fixed 30 20
    The status should equal 3
  End

  It 'LHS < RHS の場合に 1 を返すこと (小数)'
    When call sx_num_cmp_fixed 1.2 3.4
    The status should equal 1
  End

  It 'LHS == RHS の場合に 2 を返すこと (小数)'
    When call sx_num_cmp_fixed 1.23 1.23
    The status should equal 2
  End

  It 'LHS > RHS の場合に 3 を返すこと (小数)'
    When call sx_num_cmp_fixed 3.4 1.2
    The status should equal 3
  End

  It '負の数値を比較できること'
    When call sx_num_cmp_fixed -5 -3
    The status should equal 1
  End

  It '負の数値の等値比較ができること'
    When call sx_num_cmp_fixed -5 -5
    The status should equal 2
  End

  It '異符号の比較ができること (負 < 正)'
    When call sx_num_cmp_fixed -5 3
    The status should equal 1
  End

  It '異符号の比較ができること (正 > 負)'
    When call sx_num_cmp_fixed 5 -3
    The status should equal 3
  End

  It 'ゼロを正しく処理できること'
    When call sx_num_cmp_fixed 0 0
    The status should equal 2
  End

  It '無効な入力に対して 64 を返すこと'
    When call sx_num_cmp_fixed abc 1.2
    The status should equal 64
  End

  It '空文字列に対して 64 を返すこと'
    When call sx_num_cmp_fixed '' 1
    The status should equal 64
  End

  It 'SX_CFG_SKIP_CHK が 1 の時にチェックをスキップすること'
    SX_CFG_SKIP_CHK=1
    When call sx_num_cmp_fixed 10 20
    The status should equal 1
  End

  It '整数部のみの大きな値を比較できること'
    When call sx_num_cmp_fixed 9223372036854775807 9223372036854775807
    The status should equal 2
  End

  It '小数を含む大きな値を比較できること'
    When call sx_num_cmp_fixed 123456789.123456789 123456789.123456789
    The status should equal 2
  End

  It '小数位の数が異なる正規化済み数値を比較できること'
    When call sx_num_cmp_fixed 1.25 1.2
    The status should equal 3
  End
End
