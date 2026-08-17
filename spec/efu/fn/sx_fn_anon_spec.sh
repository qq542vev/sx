Describe 'sx_fn_anon -efu 環境検証'
  Include ./sx.sh

  It '正常動作'
    When run efu_run sx_fn_anon f_name 'echo "hello"'
    The status should be success
  End
End
