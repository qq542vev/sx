Describe 'sx_fn_anon -efu 環境検証'
  sxtest_load ./build/modules/sx_fn_anon.sh

  It '正常動作'
    When run efu_run sx_fn_anon f_name 'echo "hello"'
    The status should be success
  End
End
