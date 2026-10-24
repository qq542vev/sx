Describe 'sx_var_is_val -efu 環境検証'
  sxtest_load ./build/modules/sx_var_is_val.sh

  It '正常動作'
    a=1 b=2

    When run efu_run sx_var_is_val a b
    The status should be success
  End
End
