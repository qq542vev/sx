#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_num_is_i32'
  Include ./sx.sh

  Context '10進数の境界値'
    It 'i32 最大値 (2147483647) に対して成功を返すこと'
      When call sx_num_is_i32 "2147483647"
      The status should be success
    End

    It 'i32 最大値 + 1 (2147483648) に対して失敗を返すこと'
      When call sx_num_is_i32 "2147483648"
      The status should be failure
    End

    It 'i32 最小値 (-2147483648) に対して成功を返すこと'
      When call sx_num_is_i32 "-2147483648"
      The status should be success
    End

    It 'i32 最小値 - 1 (-2147483649) に対して失敗を返すこと'
      When call sx_num_is_i32 "-2147483649"
      The status should be failure
    End
  End

  Context '16進数の境界値'
    It '16進数 i32 最大値 (0x7FFFFFFF) に対して成功を返すこと'
      When call sx_num_is_i32 "0x7FFFFFFF"
      The status should be success
    End

    It '16進数 i32 最大値 + 1 (0x80000000) に対して失敗を返すこと'
      When call sx_num_is_i32 "0x80000000"
      The status should be failure
    End

    It '16進数 i32 最小値 (-0x80000000) に対して成功を返すこと'
      When call sx_num_is_i32 "-0x80000000"
      The status should be success
    End

    It '16進数 i32 最小値 - 1 (-0x80000001) に対して失敗を返すこと'
      When call sx_num_is_i32 "-0x80000001"
      The status should be failure
    End
  End

  Context '8進数の境界値'
    It '8進数 i32 最大値 (017777777777) に対して成功を返すこと'
      When call sx_num_is_i32 "017777777777"
      The status should be success
    End

    It '8進数 i32 最大値 + 1 (020000000000) に対して失敗を返すこと'
      When call sx_num_is_i32 "020000000000"
      The status should be failure
    End

    It '8進数 i32 最小値 (-020000000000) に対して成功を返すこと'
      When call sx_num_is_i32 "-020000000000"
      The status should be success
    End

    It '8進数 i32 最小値 - 1 (-020000000001) に対して失敗を返すこと'
      When call sx_num_is_i32 "-020000000001"
      The status should be failure
    End
  End

  Context '複数引数と無効な形式'
    It 'すべての引数が範囲内であれば成功を返すこと'
      When call sx_num_is_i32 "0" "2147483647" "-2147483648"
      The status should be success
    End

    It '一つでも範囲外があれば失敗を返すこと'
      When call sx_num_is_i32 "0" "2147483648"
      The status should be failure
    End

    It '数値ではない値が含まれる場合に失敗を返すこと'
      When call sx_num_is_i32 "123" "abc"
      The status should be failure
    End
  End
End
