Describe 'sx_glob_escape -efu 環境検証'
  sxtest_load ./build/modules/sx_glob_escape.sh

  It '正常動作'
    When run efu_run sx_glob_escape result 'a*b'
    The status should be success
  End
End
