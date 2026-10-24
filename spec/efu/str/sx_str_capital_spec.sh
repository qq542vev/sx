Describe 'sx_str_capital -efu 環境検証'
  sxtest_load ./build/modules/sx_str_capital.sh

  It '正常動作'
    When run efu_run sx_str_capital res "aaa bbb ccc"
    The status should be success
  End
End
