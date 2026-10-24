Describe 'sx_num_div_int -efu 環境検証'
  sxtest_load ./build/modules/sx_num_div_int.sh

  It '正常動作'

    When run efu_run sx_num_div_int d 2 100 3
    The status should be success
  End
End
