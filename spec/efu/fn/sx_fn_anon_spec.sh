Describe 'sx_fn_anon -efu 環境検証'
  Include ./spec/support/library.sh spec/efu/fn/sx_fn_anon_spec.sh sx_fn_anon

  It '正常動作'
    When run efu_run sx_fn_anon f_name 'echo "hello"'
    The status should be success
  End
End
