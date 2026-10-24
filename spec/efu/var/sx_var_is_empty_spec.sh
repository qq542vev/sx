Describe 'sx_var_is_empty -efu 環境検証'
  sxtest_load ./build/modules/sx_var_is_empty.sh

  It '正常動作'
    a= b=

    When run efu_run sx_var_is_empty a b
    The status should be success
  End
End
