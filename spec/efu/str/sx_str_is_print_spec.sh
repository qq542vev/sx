Describe 'sx_str_is_print -efu 環境検証'
  sxtest_load ./build/modules/sx_str_is_print.sh

  It '正常動作'

    When run efu_run sx_str_is_print "abcXYZ"
    The status should be success
  End
End
