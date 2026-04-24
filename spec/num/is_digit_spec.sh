Describe 'sx_num_is_digit'
  Include ./sx.sh
  It 'returns success for strings containing only digits'
    When call sx_num_is_digit "123" "0" "456"
    The status should be success
  End

  It 'returns failure for strings with non-digit characters'
    When call sx_num_is_digit "123a"
    The status should be failure
  End

  It 'returns failure for empty strings'
    When call sx_num_is_digit ""
    The status should be failure
  End
End
