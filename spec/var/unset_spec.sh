Describe 'sx_var_unset'
  Include ./sx.sh
  It 'unsets a regular variable'
    a=1
    When call sx_var_unset a
    The status should be success
    The variable a should be undefined
  End

  It 'unsets an array and all its elements'
    sx_arr_gen myarr a b c
    When call sx_var_unset myarr
    The status should be success
    The variable myarr should be undefined
    The variable myarr_len should be undefined
    The variable myarr_0 should be undefined
    The variable myarr_2 should be undefined
  End

  It 'returns failure if the variable is readonly (even if unset)'
    readonly ro_var_unset
    When call sx_var_unset ro_var_unset
    The status should equal 77
  End
End
