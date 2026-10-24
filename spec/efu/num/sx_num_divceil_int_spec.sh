Describe 'sx_num_divceil_int -efu 環境検証'
  sxtest_load ./build/modules/sx_num_divceil_int.sh

  It '正常動作'

    When run efu_run sx_num_divceil_int q -100 3
    The status should be success
  End
End
