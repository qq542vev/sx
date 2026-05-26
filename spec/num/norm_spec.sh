#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_num_norm'
  Include ./sx.sh

  It '10進整数をそのまま返すこと'
    When call sx_num_norm res 123
    The status should be success
    The variable res should equal 123
  End

  It '16進整数を10進数に変換すること'
    When call sx_num_norm res 0x10
    The status should be success
    The variable res should equal 16
  End

  It '8進整数を10進数に変換すること'
    When call sx_num_norm res 010
    The status should be success
    The variable res should equal 8
  End

  It '正の指数を正しく展開すること'
    When call sx_num_norm res "1.2e+3"
    The status should be success
    The variable res should equal 1200
  End

  It '負の指数を正しく展開すること'
    When call sx_num_norm res "1.2e-3"
    The status should be success
    The variable res should equal 0.0012
  End

  It '不要な小数点以下の0を削除すること'
    When call sx_num_norm res 6.0
    The status should be success
    The variable res should equal 6
  End

  It '整数部分の末尾の0を保持し、小数点以下のみを削除すること'
    sx_num_norm r1 10.0
    Assert [ "$r1" = "10" ]
    sx_num_norm r2 100.0
    Assert [ "$r2" = "100" ]
    sx_num_norm r3 20.0
    Assert [ "$r3" = "20" ]
  End

  It '不要な末尾の0を削除すること'
    When call sx_num_norm res 1.2300
    The status should be success
    The variable res should equal 1.23
  End

  It '指数表記展開時の先頭の不要な0を削除すること'
    sx_num_norm r1 0.01e1
    Assert [ "$r1" = "0.1" ]
  End

  It '不正な10進数形式（先頭の0など）を拒否すること'
    When call sx_num_norm res 00.1
    The status should equal 64
  End

  It '0や-0の正規化を正しく行うこと'
    sx_num_norm r1 0.0
    Assert [ "$r1" = "0" ]
    sx_num_norm r2 -0.0
    Assert [ "$r2" = "0" ]
    sx_num_norm r3 0.000
    Assert [ "$r3" = "0" ]
    sx_num_norm r4 -0e+5
    Assert [ "$r4" = "0" ]
  End

  It '符号を維持すること'
    sx_num_norm r1 -0x10
    Assert [ "$r1" = -16 ]
    sx_num_norm r2 +1.20
    Assert [ "$r2" = 1.2 ]
    sx_num_norm r3 -1.2e1
    Assert [ "$r3" = -12 ]
  End

  It '分配代入(bind)ができること'
    When call sx_num_norm a:b 0x4 05 6.0 100e2
    The status should be success
    The variable a should equal 4
    The variable b should equal "5 6 10000"
  End

  It '不正な入力に対してエラーを返すこと'
    When call sx_num_norm res "abc"
    The status should be failure
  End

  It '読み取り専用変数に対してエラーを返すこと'
    readonly TEST_RO_NORM=0
    When call sx_num_norm TEST_RO_NORM 123
    The status should equal 77
  End
End
