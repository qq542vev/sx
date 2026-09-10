#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_num_add1_nat0'
  Include ./sx.sh

  # === 基本動作 ===
  It '0に1を足すと1になること'
    When call sx_num_add1_nat0 result 0
    The status should be success
    The variable result should equal "1"
  End

  It '1に1を足すと2になること'
    When call sx_num_add1_nat0 result 1
    The status should be success
    The variable result should equal "2"
  End

  It '42に1を足すと43になること'
    When call sx_num_add1_nat0 result 42
    The status should be success
    The variable result should equal "43"
  End

  # === 単精度パス境界 (32-bit: 9桁以下) ===
  It '99999999に1を足すと100000000になること'
    When call sx_num_add1_nat0 result 99999999
    The status should be success
    The variable result should equal "100000000"
  End

  It '999999999に1を足すと1000000000になること(多倍長パスへ遷移)'
    When call sx_num_add1_nat0 result 999999999
    The status should be success
    The variable result should equal "1000000000"
  End

  # === 多倍長パス (10桁以上) ===
  It '10桁の数に1を足せること'
    When call sx_num_add1_nat0 result 1234567890
    The status should be success
    The variable result should equal "1234567891"
  End

  It '18桁の数に1を足せること'
    When call sx_num_add1_nat0 result 999999999999999999
    The status should be success
    The variable result should equal "1000000000000000000"
  End

  It '19桁の数に1を足せること'
    When call sx_num_add1_nat0 result 9999999999999999999
    The status should be success
    The variable result should equal "10000000000000000000"
  End

  It '30桁の数に1を足せること'
    When call sx_num_add1_nat0 result 999999999999999999999999999999
    The status should be success
    The variable result should equal "1000000000000000000000000000000"
  End

  # === エラーケース ===
  It '引数がない場合はエラーになること'
    When call sx_num_add1_nat0
    The status should equal 64
  End

  It '数値が指定されない場合はエラーになること'
    When call sx_num_add1_nat0 result
    The status should equal 64
  End

  It '負数を含む場合はエラーになること'
    When call sx_num_add1_nat0 result -1
    The status should equal 64
  End

  It '英字を含む場合はエラーになること'
    When call sx_num_add1_nat0 result abc
    The status should equal 64
  End

  It '符号付き正数(+42)はエラーになること'
    When call sx_num_add1_nat0 result +42
    The status should equal 64
  End

  It '無効な変数名の場合はエラーになること'
    When call sx_num_add1_nat0 123 1
    The status should equal 64
  End

  # === 設定エラー ===
  It 'SX_CFG_NUM_RANGEが不正な場合はエラーになること'
    SX_CFG_NUM_RANGE=invalid
    When call sx_num_add1_nat0 result 1
    The status should equal 78
  End
End
