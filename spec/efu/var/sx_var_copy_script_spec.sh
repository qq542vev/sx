Describe 'sx_var_copy_script -efu 環境検証'
  sxtest_load ./build/modules/sx_var_copy_script.sh

  It '正常動作'

    When run efu_run sx_var_copy_script result "a-b-c"
    The status should be success
  End
End
