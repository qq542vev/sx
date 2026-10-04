#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_num_sub_nat0'
  Include ./sx.sh

  It '引数0個で結果が0になること'
    When call sx_num_sub_nat0 result
    The status should be success
    The variable result should equal "0"
  End

  It '引数1個でその値がそのまま返ること'
    When call sx_num_sub_nat0 result 42
    The status should be success
    The variable result should equal "42"
  End

  It '2つの小さな数を減算できること'
    When call sx_num_sub_nat0 result 123 45
    The status should be success
    The variable result should equal "78"
  End

  It '同一の値の減算で0になること'
    When call sx_num_sub_nat0 result 5 5
    The status should be success
    The variable result should equal "0"
  End

  It '0を含む減算ができること'
    When call sx_num_sub_nat0 result 0 0
    The status should be success
    The variable result should equal "0"
  End

  It '正数から0の減算ができること'
    When call sx_num_sub_nat0 result 42 0
    The status should be success
    The variable result should equal "42"
  End

  It '桁借りが発生する減算ができること'
    When call sx_num_sub_nat0 result 1000 1
    The status should be success
    The variable result should equal "999"
  End

  It '窓幅を超える多倍長整数の減算ができること(9桁境界)'
    When call sx_num_sub_nat0 result 1000000000 1
    The status should be success
    The variable result should equal "999999999"
  End

  It '既定の算術域でも最上位チャンクの差が0なら先頭ゼロを残さないこと'
    When call sx_num_sub_nat0 result 1000000000 999999999
    The status should be success
    The variable result should equal "1"
  End

  It '窓幅を超える多倍長整数の減算ができること(18桁境界)'
    When call sx_num_sub_nat0 result 1000000000000000000 1
    The status should be success
    The variable result should equal "999999999999999999"
  End

  It '大きな数同士の減算ができること'
    When call sx_num_sub_nat0 result 98765432109876543210 12345678901234567890
    The status should be success
    The variable result should equal "86419753208641975320"
  End

  It '先頭ゼロが除去された大きな数の減算ができること'
    When call sx_num_sub_nat0 result 100000000000000000000 1
    The status should be success
    The variable result should equal "99999999999999999999"
  End

  Context '32bit算術シェル専用の算術域境界 (NUM_RANGE=32)'
    Before 'sx_cfg_set NUM_RANGE=32'
    Skip if '32bit算術シェル専用のため' arith_not32

    It '最上位チャンクの差が0でも先頭ゼロを残さないこと'
      When call sx_num_sub_nat0 result 2147483648 2147483644
      The status should be success
      The variable result should equal "4"
    End

    It '複数チャンクの同値減算を0に正規化すること'
      When call sx_num_sub_nat0 result 2147483648 2147483648
      The status should be success
      The variable result should equal "0"
    End
  End

  Context '算術域境界 (NUM_RANGE=64)'
    Before 'sx_cfg_set NUM_RANGE=64'
    Skip if 'ホストの算術展開が64bit未満のため' arith_lt64

    It '最上位チャンクの差が0でも先頭ゼロを残さないこと'
      When call sx_num_sub_nat0 result 9223372036854775808 9223372036854775804
      The status should be success
      The variable result should equal "4"
    End

    It '複数チャンクの同値減算を0に正規化すること'
      When call sx_num_sub_nat0 result 9223372036854775808 9223372036854775808
      The status should be success
      The variable result should equal "0"
    End
  End

  It '負数を含む場合はエラーになること'
    When call sx_num_sub_nat0 result 123 -1
    The status should equal 64
  End

  It '英字を含む場合はエラーになること'
    When call sx_num_sub_nat0 result 123 abc
    The status should equal 64
  End

  It '符号付き正数(+42)はエラーになること'
    When call sx_num_sub_nat0 result +42
    The status should equal 64
  End

  It 'チャンク境界で先頭ゼロを含む右端チャンクの減算ができること'
    When call sx_num_sub_nat0 result 10000000025 1
    The status should be success
    The variable result should equal "10000000024"
  End
End
