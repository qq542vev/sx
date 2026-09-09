Describe 'sx_arr_pop -efu 環境検証'
  Include ./sx.sh

  It '正常動作'
sx_arr_gen myarr a b c

    When run efu_run sx_arr_pop x: myarr
    The status should be success
  End

  It '要素不足で 1 を返すこと'
sx_arr_gen myarr a b c

    When run efu_run sx_arr_pop x:y:z:w: myarr
    The status should equal 1
  End
End