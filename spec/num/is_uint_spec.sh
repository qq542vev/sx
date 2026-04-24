Describe 'sx_num_is_uint'
  Include ./sx.sh
  It 'returns success for valid unsigned integers'
    When call sx_num_is_uint "123" "0" "456"
    The status should be success
  End

  It 'returns failure for integers with leading zeros'
    When call sx_num_is_uint "01"
    The status should be failure
  End

  It 'returns failure for non-digit strings'
    When call sx_num_is_uint "123a"
    The status should be failure
  End
End
