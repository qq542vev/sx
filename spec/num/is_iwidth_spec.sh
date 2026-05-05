#!/bin/sh

Describe 'sx_num_is_iwidth'
  Include ./sx.sh

  Context '8-bit signed integer'
    It 'validates boundaries'
      When call sx_num_is_iwidth 8 "127" "-128" "0177" "-0200" "0x7F" "-0x80"
      The status should be success
    End

    It 'detects overflow'
      When call sx_num_is_iwidth 8 "128"
      The status should be failure
    End

    It 'detects underflow'
      When call sx_num_is_iwidth 8 "-129"
      The status should be failure
    End
  End

  Context '16-bit signed integer'
    It 'validates boundaries'
      When call sx_num_is_iwidth 16 "32767" "-32768" "077777" "-0100000" "0x7FFF" "-0x8000"
      The status should be success
    End

    It 'detects overflow'
      When call sx_num_is_iwidth 16 "32768"
      The status should be failure
    End

    It 'detects underflow'
      When call sx_num_is_iwidth 16 "-32769"
      The status should be failure
    End
  End

  Context '32-bit signed integer'
    It 'validates boundaries'
      When call sx_num_is_iwidth 32 "2147483647" "-2147483648" "017777777777" "-020000000000" "0x7FFFFFFF" "-0x80000000"
      The status should be success
    End

    It 'detects overflow'
      When call sx_num_is_iwidth 32 "2147483648"
      The status should be failure
    End

    It 'detects underflow'
      When call sx_num_is_iwidth 32 "-2147483649"
      The status should be failure
    End
  End

  Context '64-bit signed integer'
    It 'validates boundaries'
      When call sx_num_is_iwidth 64 "9223372036854775807" "-9223372036854775808" "0777777777777777777777" "-01000000000000000000000" "0x7FFFFFFFFFFFFFFF" "-0x8000000000000000"
      The status should be success
    End

    It 'detects overflow'
      When call sx_num_is_iwidth 64 "9223372036854775808"
      The status should be failure
    End

    It 'detects underflow'
      When call sx_num_is_iwidth 64 "-9223372036854775809"
      The status should be failure
    End
  End

  Context '128-bit signed integer'
    It 'validates boundaries'
      When call sx_num_is_iwidth 128 "170141183460469231731687303715884105727" "-170141183460469231731687303715884105728"
      The status should be success
    End

    It 'detects overflow'
      When call sx_num_is_iwidth 128 "170141183460469231731687303715884105728"
      The status should be failure
    End

    It 'detects underflow'
      When call sx_num_is_iwidth 128 "-170141183460469231731687303715884105729"
      The status should be failure
    End
  End

  Context 'Invalid bit width'
    It 'returns usage error'
      When call sx_num_is_iwidth 10 "123"
      The status should equal 64
    End
  End

  Context 'Common edge cases'
    It 'validates 0 with various widths'
      When call sx_num_is_iwidth 32 "0" "+0" "-0" "0x0" "00"
      The status should be success
    End

    It 'detects invalid non-numeric strings'
      When call sx_num_is_iwidth 32 "abc" "12a" "0xG" "08"
      The status should be failure
    End

    It 'detects partial invalid strings in multiple arguments'
      When call sx_num_is_iwidth 32 "123" "2147483648"
      The status should be failure
    End
  End
End
