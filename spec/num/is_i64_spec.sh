#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_num_is_i64'
  Include ./sx.sh

  Context '10進数の境界値'
    It 'i64 最大値 (9223372036854775807) に対して成功を返すこと'
      When call sx_num_is_i64 "9223372036854775807"
      The status should be success
    End

    It 'i64 最大値 + 1 (9223372036854775808) に対して失敗を返すこと'
      When call sx_num_is_i64 "9223372036854775808"
      The status should be failure
    End

    It 'i64 最小値 (-9223372036854775808) に対して成功を返すこと'
      When call sx_num_is_i64 "-9223372036854775808"
      The status should be success
    End

    It 'i64 最小値 - 1 (-9223372036854775809) に対して失敗を返すこと'
      When call sx_num_is_i64 "-9223372036854775809"
      The status should be failure
    End
  End

  Context '16進数の境界値'
    It '16進数 i64 最大値 (0x7FFFFFFFFFFFFFFF) に対して成功を返すこと'
      When call sx_num_is_i64 "0x7FFFFFFFFFFFFFFF"
      The status should be success
    End

    It '16進数 i64 最大値 + 1 (0x8000000000000000) に対して失敗を返すこと'
      When call sx_num_is_i64 "0x8000000000000000"
      The status should be failure
    End

    It '16進数 i64 最小値 (-0x8000000000000000) に対して成功を返すこと'
      When call sx_num_is_i64 "-0x8000000000000000"
      The status should be success
    End

    It '16進数 i64 最小値 - 1 (-0x8000000000000001) に対して失敗を返すこと'
      When call sx_num_is_i64 "-0x8000000000000001"
      The status should be failure
    End
  End

  Context '8進数の境界値'
    It '8進数 i64 最大値 (0777777777777777777777) に対して成功を返すこと'
      When call sx_num_is_i64 "0777777777777777777777"
      The status should be success
    End

    It '8進数 i64 最大値 + 1 (01000000000000000000000) に対して失敗を返すこと'
      When call sx_num_is_i64 "01000000000000000000000"
      The status should be failure
    End

    It '8進数 i64 最小値 (-01000000000000000000000) に対して成功を返すこと'
      When call sx_num_is_i64 "-01000000000000000000000"
      The status should be success
    End

    It '8進数 i64 最小値 - 1 (-01000000000000000000001) に対して失敗を返すこと'
      When call sx_num_is_i64 "-01000000000000000000001"
      The status should be failure
    End
  End

  Context '複数引数と無効な形式'
    It 'すべての引数が範囲内であれば成功を返すこと'
      When call sx_num_is_i64 "0" "9223372036854775807" "-9223372036854775808"
      The status should be success
    End

    It '一つでも範囲外があれば失敗を返すこと'
      When call sx_num_is_i64 "0" "9223372036854775808"
      The status should be failure
    End
  End
End
