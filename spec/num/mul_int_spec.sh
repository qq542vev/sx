#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_num_mul_int'
  Include ./sx.sh

  It '引数0個で結果が1になること'
    When call sx_num_mul_int result
    The status should be success
    The variable result should equal "1"
  End

  It '引数1個(正数)でその値がそのまま返ること'
    When call sx_num_mul_int result 42
    The status should be success
    The variable result should equal "42"
  End

  It '引数1個(負数)でその値がそのまま返ること'
    When call sx_num_mul_int result -7
    The status should be success
    The variable result should equal "-7"
  End

  It '正数同士の乗算ができること'
    When call sx_num_mul_int result 5 3
    The status should be success
    The variable result should equal "15"
  End

  It '負数同士の乗算ができること'
    When call sx_num_mul_int result -5 -3
    The status should be success
    The variable result should equal "15"
  End

  It '正数と負数の乗算(負結果)ができること'
    When call sx_num_mul_int result 5 -3
    The status should be success
    The variable result should equal "-15"
  End

  It '負数と正数の乗算(負結果)ができること'
    When call sx_num_mul_int result -5 3
    The status should be success
    The variable result should equal "-15"
  End

  It '0を掛けると0になること'
    When call sx_num_mul_int result 0 123
    The status should be success
    The variable result should equal "0"
  End

  It '0を掛けられる側も0になること'
    When call sx_num_mul_int result 123 0
    The status should be success
    The variable result should equal "0"
  End

  It '両方0の場合0になること'
    When call sx_num_mul_int result 0 0
    The status should be success
    The variable result should equal "0"
  End

  It '正数と負数の乗算で0になること'
    When call sx_num_mul_int result -5 0
    The status should be success
    The variable result should equal "0"
  End

  It '1を掛けると元の値が返ること'
    When call sx_num_mul_int result 123 1
    The status should be success
    The variable result should equal "123"
  End

  It '1を掛けられる側も元の値が返ること'
    When call sx_num_mul_int result 1 -456
    The status should be success
    The variable result should equal "-456"
  End

  It '3つ以上の数を乗算できること'
    When call sx_num_mul_int result 2 -3 4
    The status should be success
    The variable result should equal "-24"
  End

  It '負数が偶数の複数乗算で正になること'
    When call sx_num_mul_int result -2 -3 -4 -5
    The status should be success
    The variable result should equal "120"
  End

  It '負数が奇数の複数乗算で負になること'
    When call sx_num_mul_int result -2 -3 -4
    The status should be success
    The variable result should equal "-24"
  End

  It '0を含む複数乗算で0になること'
    When call sx_num_mul_int result 123 0 -456
    The status should be success
    The variable result should equal "0"
  End

  It '大きな数の乗算ができること'
    When call sx_num_mul_int result 12345678901234567890 -9876543210987654321
    The status should be success
    The variable result should equal "-121932631137021795223746380111126352690"
  End

  It '英字を含む場合はエラーになること'
    When call sx_num_mul_int result 123 abc
    The status should equal 64
  End

  It '8進数を含む場合はエラーになること'
    When call sx_num_mul_int result 123 0123
    The status should equal 64
  End

  Describe 'SX_CFG_NUM_RANGE invalid'
    Before 'SX_CFG_NUM_RANGE=99'

    It 'SX_CFG_NUM_RANGEが不正な場合はエラーになること'
      When call sx_num_mul_int result 123 456
      The status should equal 78
    End
  End
End
