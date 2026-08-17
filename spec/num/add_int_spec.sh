#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_num_add_int'
  Include ./sx.sh

  It '引数0個で結果が0になること'
    When call sx_num_add_int result
    The status should be success
    The variable result should equal "0"
  End

  It '引数1個でその値がそのまま返ること'
    When call sx_num_add_int result 42
    The status should be success
    The variable result should equal "42"
  End

  It '正数同士の加算ができること'
    When call sx_num_add_int result 5 3
    The status should be success
    The variable result should equal "8"
  End

  It '負数同士の加算ができること'
    When call sx_num_add_int result -5 -3
    The status should be success
    The variable result should equal "-8"
  End

  It '正数と負数の加算(正優勢)ができること'
    When call sx_num_add_int result 10 -3
    The status should be success
    The variable result should equal "7"
  End

  It '正数と負数の加算(負優勢)ができること'
    When call sx_num_add_int result 3 -10
    The status should be success
    The variable result should equal "-7"
  End

  It '負数と正数の加算(負優勢)ができること'
    When call sx_num_add_int result -10 3
    The status should be success
    The variable result should equal "-7"
  End

  It '負数と正数の加算(正優勢)ができること'
    When call sx_num_add_int result -3 10
    The status should be success
    The variable result should equal "7"
  End

  It '絶対値が等しい異符号で0になること'
    When call sx_num_add_int result 5 -5
    The status should be success
    The variable result should equal "0"
  End

  It '絶対値が等しい異符号(逆順)で0になること'
    When call sx_num_add_int result -5 5
    The status should be success
    The variable result should equal "0"
  End

  It '3つ以上の数を加算できること'
    When call sx_num_add_int result 1 -2 3
    The status should be success
    The variable result should equal "2"
  End

  It '0を含む加算ができること'
    When call sx_num_add_int result 0 -5 5
    The status should be success
    The variable result should equal "0"
  End

  It '桁上がりが発生する加算ができること'
    When call sx_num_add_int result 999999999 -1
    The status should be success
    The variable result should equal "999999998"
  End

  It '大きな数の加算ができること'
    When call sx_num_add_int result 12345678901234567890 -9876543210987654321
    The status should be success
    The variable result should equal "2469135690246913569"
  End

  It '英字を含む場合はエラーになること'
    When call sx_num_add_int result 123 abc
    The status should equal 64
  End

  It '8進数を含む場合はエラーになること'
    When call sx_num_add_int result 123 0123
    The status should equal 64
  End
End
