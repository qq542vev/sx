Describe 'sx_var_is_empty'
  Include ./sx.sh
  It 'returns success if all variables are set and empty'
    a="" b=""
    When call sx_var_is_empty a b
    The status should be success
  End

  It 'returns failure if any variable is non-empty'
    a="" b=1
    When call sx_var_is_empty a b
    The status should be failure
  End

  It 'returns failure if any variable is unset'
    unset c
    When call sx_var_is_empty c
    The status should be failure
  End
End
