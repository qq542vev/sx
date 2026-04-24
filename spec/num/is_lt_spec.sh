Describe 'sx_num_is_lt'
  Include ./sx.sh
  It 'returns success if numbers are in strictly increasing order'
    When call sx_num_is_lt 1 2 3
    The status should be success
  End

  It 'returns failure if numbers are not strictly increasing'
    When call sx_num_is_lt 1 2 2 3
    The status should be failure
  End
End
