#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_num_add_nat0'
  Include ./sx.sh

  It '引数0個で結果が0になること'
    When call sx_num_add_nat0 result
    The status should be success
    The variable result should equal "0"
  End

  It '引数1個でその値がそのまま返ること'
    When call sx_num_add_nat0 result 42
    The status should be success
    The variable result should equal "42"
  End

  It '2つの小さな数を加算できること'
    When call sx_num_add_nat0 result 123 456
    The status should be success
    The variable result should equal "579"
  End

  It '桁上がりが発生する加算ができること'
    When call sx_num_add_nat0 result 999 1
    The status should be success
    The variable result should equal "1000"
  End

  It '3つ以上の数を加算できること'
    When call sx_num_add_nat0 result 1 2 3 4 5
    The status should be success
    The variable result should equal "15"
  End

  It '0を含む加算ができること'
    When call sx_num_add_nat0 result 0 0 0
    The status should be success
    The variable result should equal "0"
  End

  It 'ゼロと正数の加算ができること'
    When call sx_num_add_nat0 result 0 42
    The status should be success
    The variable result should equal "42"
  End

  It '窓幅を超える多倍長整数の加算ができること(9桁境界)'
    When call sx_num_add_nat0 result 999999999 1
    The status should be success
    The variable result should equal "1000000000"
  End

  It '窓幅を超える多倍長整数の加算ができること(18桁境界)'
    When call sx_num_add_nat0 result 999999999999999999 1
    The status should be success
    The variable result should equal "1000000000000000000"
  End

  It '大きな数同士の加算ができること'
    When call sx_num_add_nat0 result 12345678901234567890 98765432109876543210
    The status should be success
    The variable result should equal "111111111011111111100"
  End

  It '非常に大きな数の加算ができること(30桁)'
    When call sx_num_add_nat0 result 999999999999999999999999999999 1
    The status should be success
    The variable result should equal "1000000000000000000000000000000"
  End

  It '複数の大きな数を加算できること'
    When call sx_num_add_nat0 result 100000000000000000000 200000000000000000000 300000000000000000000
    The status should be success
    The variable result should equal "600000000000000000000"
  End

  It 'すべての桁が桁上がりになる加算ができること'
    When call sx_num_add_nat0 result 999999999999999999 999999999999999999
    The status should be success
    The variable result should equal "1999999999999999998"
  End

  It '同一の大きな数を加算できること(2倍)'
    When call sx_num_add_nat0 result 55555555555555555555 55555555555555555555
    The status should be success
    The variable result should equal "111111111111111111110"
  End

  It '負数を含む場合はエラーになること'
    When call sx_num_add_nat0 result 123 -1
    The status should equal 64
  End

  It '英字を含む場合はエラーになること'
    When call sx_num_add_nat0 result 123 abc
    The status should equal 64
  End

  It '符号付き正数(+42)はエラーになること'
    When call sx_num_add_nat0 result +42
    The status should equal 64
  End

  It 'チャンク境界で先頭ゼロを含む右端チャンクの加算ができること'
    When call sx_num_add_nat0 result 32239684 70066520000
    The status should be success
    The variable result should equal "70098759684"
  End
End
