Describe 'sx_str_any'
  Include ./sx.sh
  It 'returns success if the first argument matches any subsequent argument'
    When call sx_str_any "a" "x" "a" "y"
    The status should be success
  End

  It 'returns failure if no match is found'
    When call sx_str_any "a" "x" "y" "z"
    The status should be failure
  End

  It 'returns failure if only one argument is provided'
    When call sx_str_any "a"
    The status should be failure
  End
End
