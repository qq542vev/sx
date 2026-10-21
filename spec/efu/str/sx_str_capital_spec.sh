Describe 'sx_str_capital -efu 環境検証'
  Include ./spec/support/library.sh sx_str_capital

  It '正常動作'
    When run efu_run sx_str_capital res "aaa bbb ccc"
    The status should be success
  End
End
