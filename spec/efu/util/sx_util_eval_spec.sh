Describe 'sx_util_eval -efu 環境検証'
  Include ./spec/support/library.sh spec/efu/util/sx_util_eval_spec.sh sx_util_eval

  It '正常動作'

    When run efu_run sx_util_eval 'result=success'
    The status should be success
  End
End
