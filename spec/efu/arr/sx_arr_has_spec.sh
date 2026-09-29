Describe 'sx_arr_has -efu 環境検証'
  Include ./sx.sh

  It '正常動作'
sx_arr_gen myarr a b c

    When run efu_run sx_arr_has myarr 0
    The status should be success
  End

  It '範囲指定ができること'
sx_arr_gen myarr a b c d e

    When run efu_run sx_arr_has myarr 3:0:-1
    The status should be success
  End

  It '終端省略ができること'
sx_arr_gen myarr a b c d e

    When run efu_run sx_arr_has myarr 2::-1
    The status should be success
  End
End