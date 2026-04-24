Describe 'sx_var_is_name'
  Include ./sx.sh
  It 'returns success for valid variable names'
    When call sx_var_is_name var1 _var VAR_123
    The status should be success
  End

  It 'returns failure for invalid variable names'
    When call sx_var_is_name 1var
    The status should be failure
  End

  It 'returns failure for names with invalid characters'
    When call sx_var_is_name "var-name"
    The status should be failure
  End

  It 'returns failure if any of the names are invalid'
    When call sx_var_is_name var1 1var
    The status should be failure
  End
End
