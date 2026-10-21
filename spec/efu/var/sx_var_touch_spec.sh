Describe 'sx_var_touch -efu 環境検証'
  Include ./spec/support/library.sh spec/efu/var/sx_var_touch_spec.sh sx_arr_gen sx_var_touch

  It '正常動作'
    sx_arr_gen myarr a b c

    When run efu_run sx_var_touch myarr
    The status should be success
  End
End
