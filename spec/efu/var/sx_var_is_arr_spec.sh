Describe 'sx_var_is_arr -efu 環境検証'
  Include ./sx.sh

  It '正常動作'
    sx_arr_gen myarr a b c

    When run efu_run sx_var_is_arr myarr
    The status should be success
  End
End
