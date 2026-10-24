Describe 'sx_str_lower -efu 環境検証'
  sxtest_load ./build/modules/sx_str_lower.sh

  It '正常動作'
    When run efu_run sx_str_lower res "ABC"
    The status should be success
  End
End
