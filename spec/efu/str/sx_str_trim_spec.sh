Describe 'sx_str_trim -efu 環境検証'
  sxtest_load ./build/modules/sx_str_trim.sh

  It '正常動作'
    When run efu_run sx_str_trim res "  hello  "
    The status should be success
  End
End
