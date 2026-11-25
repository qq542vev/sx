Describe 'sx_arr_is_slice -efu 環境検証'
  sxtest_load ./build/modules/sx_arr_is_slice.sh

  It '正常動作'
    When run efu_run sx_arr_is_slice 0:5:2
    The status should be success
  End
End
