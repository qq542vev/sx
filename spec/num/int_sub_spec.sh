#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_num_int_sub'
  Include ./sx.sh

  It '引数0個で結果が0になること'
    When call sx_num_int_sub result
    The status should be success
    The variable result should equal "0"
  End

  It '引数1個でその値がそのまま返ること'
    When call sx_num_int_sub result 42
    The status should be success
    The variable result should equal "42"
  End

  It '正数同士の減算ができること'
    When call sx_num_int_sub result 10 3
    The status should be success
    The variable result should equal "7"
  End

  It '正数同士の減算(負結果)ができること'
    When call sx_num_int_sub result 3 10
    The status should be success
    The variable result should equal "-7"
  End

  It '正数から負数の減算ができること'
    When call sx_num_int_sub result 10 -3
    The status should be success
    The variable result should equal "13"
  End

  It '負数から正数の減算ができること'
    When call sx_num_int_sub result -10 3
    The status should be success
    The variable result should equal "-13"
  End

  It '負数同士の減算ができること'
    When call sx_num_int_sub result -10 -3
    The status should be success
    The variable result should equal "-7"
  End

  It '自己減算で0になること'
    When call sx_num_int_sub result 5 5
    The status should be success
    The variable result should equal "0"
  End

  It '3つ以上の数を減算できること'
    When call sx_num_int_sub result 20 5 3
    The status should be success
    The variable result should equal "12"
  End

  It '負数を含む3つ以上の減算ができること'
    When call sx_num_int_sub result 10 -2 4
    The status should be success
    The variable result should equal "8"
  End

  It '0を含む減算ができること'
    When call sx_num_int_sub result 5 2 3
    The status should be success
    The variable result should equal "0"
  End

  It '英字を含む場合はエラーになること'
    When call sx_num_int_sub result 123 abc
    The status should equal 64
  End

  It '8進数を含む場合はエラーになること'
    When call sx_num_int_sub result 123 0123
    The status should equal 64
  End
End
