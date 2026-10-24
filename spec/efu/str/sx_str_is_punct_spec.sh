Describe 'sx_str_is_punct -efu 環境検証'
  sxtest_load ./build/modules/sx_str_is_punct.sh

  It '正常動作'

    When run efu_run sx_str_is_punct "!@#"
    The status should be success
  End
End
