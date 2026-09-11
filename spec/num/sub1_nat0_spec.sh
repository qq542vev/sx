#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_num_sub1_nat0'
  Include ./sx.sh

  # === 基本動作 ===
  It '1から1を引くと0になること'
    When call sx_num_sub1_nat0 result 1
    The status should be success
    The variable result should equal "0"
  End

  It '2から1を引くと1になること'
    When call sx_num_sub1_nat0 result 2
    The status should be success
    The variable result should equal "1"
  End

  It '42から1を引くと41になること'
    When call sx_num_sub1_nat0 result 42
    The status should be success
    The variable result should equal "41"
  End

  # === 単精度パス境界 (32-bit: 9桁以下) ===
  It '100000000から1を引くと99999999になること'
    When call sx_num_sub1_nat0 result 100000000
    The status should be success
    The variable result should equal "99999999"
  End

  It '1000000000から1を引くと999999999になること(多倍長パスへ遷移)'
    When call sx_num_sub1_nat0 result 1000000000
    The status should be success
    The variable result should equal "999999999"
  End

  # === 多倍長パス (10桁以上) ===
  It '10桁の数から1を引けること'
    When call sx_num_sub1_nat0 result 1234567890
    The status should be success
    The variable result should equal "1234567889"
  End

  It '18桁の数から1を引けること'
    When call sx_num_sub1_nat0 result 1000000000000000000
    The status should be success
    The variable result should equal "999999999999999999"
  End

  It '19桁の数から1を引けること'
    When call sx_num_sub1_nat0 result 10000000000000000000
    The status should be success
    The variable result should equal "9999999999999999999"
  End

  It '30桁の数から1を引けること'
    When call sx_num_sub1_nat0 result 1000000000000000000000000000000
    The status should be success
    The variable result should equal "999999999999999999999999999999"
  End

  # === エラーケース ===
  It '引数がない場合はエラーになること'
    When call sx_num_sub1_nat0
    The status should equal 64
  End

  It '数値が指定されない場合はエラーになること'
    When call sx_num_sub1_nat0 result
    The status should equal 64
  End

  It '0から1を引こうとするとエラーになること'
    When call sx_num_sub1_nat0 result 0
    The status should equal 64
  End

  It '負数を含む場合はエラーになること'
    When call sx_num_sub1_nat0 result -1
    The status should equal 64
  End

  It '英字を含む場合はエラーになること'
    When call sx_num_sub1_nat0 result abc
    The status should equal 64
  End

  It '符号付き正数(+42)はエラーになること'
    When call sx_num_sub1_nat0 result +42
    The status should equal 64
  End

  It '無効な変数名の場合はエラーになること'
    When call sx_num_sub1_nat0 123 1
    The status should equal 64
  End

  # === 設定エラー ===
  It 'SX_CFG_NUM_RANGEが不正な場合はエラーになること'
    SX_CFG_NUM_RANGE=invalid
    When call sx_num_sub1_nat0 result 1
    The status should equal 78
  End
End