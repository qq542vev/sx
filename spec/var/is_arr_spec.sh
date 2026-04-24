Describe 'sx_var_is_arr'
  Include ./sx.sh
  It 'returns success for sx arrays'
    sx_arr_gen myarr a b
    When call sx_var_is_arr myarr
    The status should be success
  End

  It 'returns failure for regular variables'
    regular_var="val"
    When call sx_var_is_arr regular_var
    The status should be failure
  End
End
