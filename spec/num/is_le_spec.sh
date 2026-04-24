Describe 'sx_num_is_le'
  Include ./sx.sh
  It 'returns success if numbers are in non-decreasing order'
    When call sx_num_is_le 1 2 2 3
    The status should be success
  End

  It 'returns failure if numbers are not in non-decreasing order'
    When call sx_num_is_le 1 3 2
    The status should be failure
  End

  It 'returns failure for non-numeric input'
    When call sx_num_is_le 1 "a"
    The status should be failure
  End
End
