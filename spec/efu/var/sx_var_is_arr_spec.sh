Describe 'sx_var_is_arr -efu 環境検証'
  Include ./spec/support/library.sh spec/efu/var/sx_var_is_arr_spec.sh sx_arr_gen sx_var_is_arr

  It '正常動作'
    sx_arr_gen myarr a b c

    When run efu_run sx_var_is_arr myarr
    The status should be success
  End
End
