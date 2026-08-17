Describe 'sx_arr_pop -efu 環境検証'
  Include ./sx.sh

  It '正常動作'
sx_arr_gen myarr a b c

    When run efu_run sx_arr_pop myarr
    The status should be success
  End
End
