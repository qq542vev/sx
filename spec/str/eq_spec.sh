Describe 'sx_str_eq'
  Include ./sx.sh
  It 'returns success if all arguments are equal'
    When call sx_str_eq "a" "a" "a"
    The status should be success
  End

  It 'returns failure if any argument is different'
    When call sx_str_eq "a" "a" "b"
    The status should be failure
  End

  It 'returns success for one argument'
    When call sx_str_eq "a"
    The status should be success
  End

  It 'returns success for no arguments'
    When call sx_str_eq
    The status should be success
  End
End
