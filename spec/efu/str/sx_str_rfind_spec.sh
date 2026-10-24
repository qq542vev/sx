Describe 'sx_str_rfind -efu 環境検証'
  sxtest_load ./build/modules/sx_str_rfind.sh

  It '正常動作'

    When run efu_run sx_str_rfind res "hello world" "world"
    The status should be success
  End
End
