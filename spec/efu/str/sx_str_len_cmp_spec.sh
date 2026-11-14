Describe 'sx_str_len_cmp -efu 環境検証'
  sxtest_load ./build/modules/sx_str_len_cmp.sh

  It '正常動作'
    When run efu_run sx_str_len_cmp "ab" "abc"
    The status should equal 1
  End

  It '正常動作等長'
    When run efu_run sx_str_len_cmp "abc" "abc"
    The status should equal 2
  End

  It '正常動作長い'
    When run efu_run sx_str_len_cmp "abc" "ab"
    The status should equal 3
  End
End
