Describe 'sx_var_is_set'
  Include ./sx.sh
  It 'returns success if all variables are set'
    a=1 b=2
    When call sx_var_is_set a b
    The status should be success
  End

  It 'returns failure if any variable is unset'
    a=1
    unset b
    When call sx_var_is_set a b
    The status should be failure
  End

  It 'returns failure for non-existent variables'
    unset c
    When call sx_var_is_set c
    The status should be failure
  End
End
