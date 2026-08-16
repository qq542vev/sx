#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_num_int_sub_abs'
  Include ./sx.sh

  It '引数0個で結果が0になること'
    When call sx_num_int_sub_abs result
    The status should be success
    The variable result should equal "0"
  End

  It '引数1個でその値がそのまま返ること'
    When call sx_num_int_sub_abs result 42
    The status should be success
    The variable result should equal "42"
  End

  It '2つの小さな数を減算できること'
    When call sx_num_int_sub_abs result 123 45
    The status should be success
    The variable result should equal "78"
  End

  It '同一の値の減算で0になること'
    When call sx_num_int_sub_abs result 5 5
    The status should be success
    The variable result should equal "0"
  End

  It '0を含む減算ができること'
    When call sx_num_int_sub_abs result 0 0
    The status should be success
    The variable result should equal "0"
  End

  It '正数から0の減算ができること'
    When call sx_num_int_sub_abs result 42 0
    The status should be success
    The variable result should equal "42"
  End

  It '桁借りが発生する減算ができること'
    When call sx_num_int_sub_abs result 1000 1
    The status should be success
    The variable result should equal "999"
  End

  It '窓幅を超える多倍長整数の減算ができること(9桁境界)'
    When call sx_num_int_sub_abs result 1000000000 1
    The status should be success
    The variable result should equal "999999999"
  End

  It '窓幅を超える多倍長整数の減算ができること(18桁境界)'
    When call sx_num_int_sub_abs result 1000000000000000000 1
    The status should be success
    The variable result should equal "999999999999999999"
  End

  It '大きな数同士の減算ができること'
    When call sx_num_int_sub_abs result 98765432109876543210 12345678901234567890
    The status should be success
    The variable result should equal "86419753208641975320"
  End

  It '先頭ゼロが除去された大きな数の減算ができること'
    When call sx_num_int_sub_abs result 100000000000000000000 1
    The status should be success
    The variable result should equal "99999999999999999999"
  End

  It '負数を含む場合はエラーになること'
    When call sx_num_int_sub_abs result 123 -1
    The status should equal 64
  End

  It '英字を含む場合はエラーになること'
    When call sx_num_int_sub_abs result 123 abc
    The status should equal 64
  End

  It '符号付き正数(+42)はエラーになること'
    When call sx_num_int_sub_abs result +42
    The status should equal 64
  End

  It 'チャンク境界で先頭ゼロを含む右端チャンクの減算ができること'
    When call sx_num_int_sub_abs result 10000000025 1
    The status should be success
    The variable result should equal "10000000024"
  End
End
