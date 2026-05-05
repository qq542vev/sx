#!/bin/sh

Describe 'sx_num_is_int_width'
  Include ./sx.sh

  Context '8ビット符号付き整数'
    It '境界値を検証すること'
      When call sx_num_is_int_width 8 "127" "-128" "0177" "-0200" "0x7F" "-0x80"
      The status should be success
    End

    It 'オーバーフローを検出すること'
      When call sx_num_is_int_width 8 "128"
      The status should be failure
    End

    It 'アンダーフローを検出すること'
      When call sx_num_is_int_width 8 "-129"
      The status should be failure
    End
  End

  Context '16ビット符号付き整数'
    It '境界値を検証すること'
      When call sx_num_is_int_width 16 "32767" "-32768" "077777" "-0100000" "0x7FFF" "-0x8000"
      The status should be success
    End

    It 'オーバーフローを検出すること'
      When call sx_num_is_int_width 16 "32768"
      The status should be failure
    End

    It 'アンダーフローを検出すること'
      When call sx_num_is_int_width 16 "-32769"
      The status should be failure
    End
  End

  Context '32ビット符号付き整数'
    It '境界値を検証すること'
      When call sx_num_is_int_width 32 "2147483647" "-2147483648" "017777777777" "-020000000000" "0x7FFFFFFF" "-0x80000000"
      The status should be success
    End

    It 'オーバーフローを検出すること'
      When call sx_num_is_int_width 32 "2147483648"
      The status should be failure
    End

    It 'アンダーフローを検出すること'
      When call sx_num_is_int_width 32 "-2147483649"
      The status should be failure
    End
  End

  Context '64ビット符号付き整数'
    It '境界値を検証すること'
      When call sx_num_is_int_width 64 "9223372036854775807" "-9223372036854775808" "0777777777777777777777" "-01000000000000000000000" "0x7FFFFFFFFFFFFFFF" "-0x8000000000000000"
      The status should be success
    End

    It 'オーバーフローを検出すること'
      When call sx_num_is_int_width 64 "9223372036854775808"
      The status should be failure
    End

    It 'アンダーフローを検出すること'
      When call sx_num_is_int_width 64 "-9223372036854775809"
      The status should be failure
    End
  End

  Context '128ビット符号付き整数'
    It '境界値を検証すること'
      When call sx_num_is_int_width 128 "170141183460469231731687303715884105727" "-170141183460469231731687303715884105728"
      The status should be success
    End

    It 'オーバーフローを検出すること'
      When call sx_num_is_int_width 128 "170141183460469231731687303715884105728"
      The status should be failure
    End

    It 'アンダーフローを検出すること'
      When call sx_num_is_int_width 128 "-170141183460469231731687303715884105729"
      The status should be failure
    End
  End

  Context '無効なビット幅'
    It 'EX_USAGE を返すこと'
      When call sx_num_is_int_width 10 "123"
      The status should equal 64
    End
  End

  Context '一般的なエッジケース'
    It '様々なビット幅で0を検証すること'
      When call sx_num_is_int_width 32 "0" "+0" "-0" "0x0" "00"
      The status should be success
    End

    It '無効な非数値文字列を検出すること'
      When call sx_num_is_int_width 32 "abc" "12a" "0xG" "08"
      The status should be failure
    End

    It '複数の引数内の部分的な無効文字列を検出すること'
      When call sx_num_is_int_width 32 "123" "2147483648"
      The status should be failure
    End
  End
End
