Describe 'sx_var_touch'
  Include ./sx.sh
  It 'updates the revision of a variable'
    sx_arr_gen myarr a
    old_val="${myarr}"
    When call sx_var_touch myarr
    The status should be success
    The variable myarr should not equal "${old_val}"
    The variable myarr should start with "array-sx-sig-"
  End
End
