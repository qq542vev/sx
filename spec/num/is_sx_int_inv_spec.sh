Describe 'sx_num_is_sx_int_inv'
  Include ./sx.sh

  It 'accepts invertible integers'
    When call sx_num_is_sx_int_inv "0" "1" "-1" "123" "-123"
    The status should be success
  End

  It 'rejects INT_MIN'
    # Assuming default 32-bit range
    When call sx_num_is_sx_int_inv "-2147483648"
    The status should be failure
  End

  It 'accepts values just above INT_MIN'
    When call sx_num_is_sx_int_inv "-2147483647"
    The status should be success
  End

  It 'rejects non-integers'
    When call sx_num_is_sx_int_inv "abc"
    The status should be failure
  End

  It 'rejects out of range values'
    When call sx_num_is_sx_int_inv "2147483648"
    The status should be failure
  End

  It 'rejects if any argument is invalid'
    When call sx_num_is_sx_int_inv "1" "-2147483648" "2"
    The status should be failure
  End
End
