Describe 'sx_var_has_val'
  Include ./sx.sh
  It 'returns success if all variables have non-empty values'
    a=1 b=0
    When call sx_var_has_val a b
    The status should be success
  End

  It 'returns failure if any variable is empty'
    a=1 b=""
    When call sx_var_has_val a b
    The status should be failure
  End

  It 'returns failure if any variable is unset'
    a=1
    unset c
    When call sx_var_has_val a c
    The status should be failure
  End
End
