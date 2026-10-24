Describe 'sx_str_etrim -efu 環境検証'
  sxtest_load ./build/modules/sx_str_etrim.sh

  It '正常動作'
    When run efu_run sx_str_etrim res "hello  "
    The status should be success
  End
End
