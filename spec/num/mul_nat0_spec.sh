#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_num_mul_nat0'
  Include ./sx.sh

  It '0を掛けると0になること'
    When call sx_num_mul_nat0 result 0 123
    The status should be success
    The variable result should equal "0"
  End

  It '0を掛けられる側も0になること'
    When call sx_num_mul_nat0 result 123 0
    The status should be success
    The variable result should equal "0"
  End

  It '両方0の場合0になること'
    When call sx_num_mul_nat0 result 0 0
    The status should be success
    The variable result should equal "0"
  End

  It '1を掛けると元の値が返ること'
    When call sx_num_mul_nat0 result 123 1
    The status should be success
    The variable result should equal "123"
  End

  It '1を掛けられる側も元の値が返ること'
    When call sx_num_mul_nat0 result 1 456
    The status should be success
    The variable result should equal "456"
  End

  It '2つの小さな数を乗算できること'
    When call sx_num_mul_nat0 result 123 456
    The status should be success
    The variable result should equal "56088"
  End

  It '桁上がりが発生する乗算ができること'
    When call sx_num_mul_nat0 result 999 999
    The status should be success
    The variable result should equal "998001"
  End

  It '大きな数と1桁の乗算ができること'
    When call sx_num_mul_nat0 result 999999999 2
    The status should be success
    The variable result should equal "1999999998"
  End

  It '窓幅を超える多倍長整数の乗算ができること(9桁境界)'
    When call sx_num_mul_nat0 result 999999999 999999999
    The status should be success
    The variable result should equal "999999998000000001"
  End

  It '2つの大きな数を乗算できること(10桁)'
    When call sx_num_mul_nat0 result 1234567890 9876543210
    The status should be success
    The variable result should equal "12193263111263526900"
  End

  It '30桁の数と1桁の乗算ができること'
    When call sx_num_mul_nat0 result 999999999999999999999999999999 3
    The status should be success
    The variable result should equal "2999999999999999999999999999997"
  End

  It '異なる桁の数同士の乗算ができること'
    When call sx_num_mul_nat0 result 12345 67890
    The status should be success
    The variable result should equal "838102050"
  End

  It '途中に0を含む乗算ができること'
    When call sx_num_mul_nat0 result 102030405 3
    The status should be success
    The variable result should equal "306091215"
  End

  It '乗数に0を含む桁がある乗算ができること'
    When call sx_num_mul_nat0 result 123 101
    The status should be success
    The variable result should equal "12423"
  End

  It 'すべての桁が9の大きな数の乗算ができること(20桁)'
    When call sx_num_mul_nat0 result 99999999999999999999 99999999999999999999
    The status should be success
    The variable result should equal "9999999999999999999800000000000000000001"
  End

  It '被乗数の末尾ゼロを除去して乗算できること'
    When call sx_num_mul_nat0 result 1230000 456
    The status should be success
    The variable result should equal "560880000"
  End

  It '乗数の末尾ゼロを除去して乗算できること'
    When call sx_num_mul_nat0 result 123 4560000
    The status should be success
    The variable result should equal "560880000"
  End

  It '両方の末尾ゼロを除去して乗算できること'
    When call sx_num_mul_nat0 result 1230000 4560000
    The status should be success
    The variable result should equal "5608800000000"
  End

  It '桁上がりと末尾ゼロ除去が共存できること'
    When call sx_num_mul_nat0 result 999000 999000
    The status should be success
    The variable result should equal "998001000000"
  End

  It '両オペランドが10^kでもpower-of-10早期returnとの共存が正しいこと'
    When call sx_num_mul_nat0 result 1000 5000
    The status should be success
    The variable result should equal "5000000"
  End

  It '引数0個で結果が1になること'
    When call sx_num_mul_nat0 result
    The status should be success
    The variable result should equal "1"
  End

  It '引数1個でその値がそのまま返ること'
    When call sx_num_mul_nat0 result 42
    The status should be success
    The variable result should equal "42"
  End

  It '3つ以上の数を乗算できること'
    When call sx_num_mul_nat0 result 2 3 4
    The status should be success
    The variable result should equal "24"
  End

  It '複数の大きな数を乗算できること'
    When call sx_num_mul_nat0 result 100 200 300
    The status should be success
    The variable result should equal "6000000"
  End

  It '途中に0を含む乗算ができること'
    When call sx_num_mul_nat0 result 123 0 456
    The status should be success
    The variable result should equal "0"
  End

  It '負数を含む場合はエラーになること'
    When call sx_num_mul_nat0 result 123 -1
    The status should equal 64
  End

  It '英字を含む場合はエラーになること'
    When call sx_num_mul_nat0 result 123 abc
    The status should equal 64
  End

  It '符号付き正数(+42)はエラーになること'
    When call sx_num_mul_nat0 result +42
    The status should equal 64
  End

  Describe 'SX_CFG_NUM_RANGE invalid'
    Before 'SX_CFG_NUM_RANGE=99'

    It 'SX_CFG_NUM_RANGEが不正な場合はエラーになること'
      When call sx_num_mul_nat0 result 123 456
      The status should equal 78
    End
  End
End
