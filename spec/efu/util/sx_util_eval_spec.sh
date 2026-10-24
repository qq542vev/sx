Describe 'sx_util_eval -efu 環境検証'
  sxtest_load ./build/modules/sx_util_eval.sh

  It '正常動作'

    When run efu_run sx_util_eval 'result=success'
    The status should be success
  End
End
