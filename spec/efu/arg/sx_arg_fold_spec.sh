Describe 'sx_arg_fold -efu 環境検証'
  Include ./sx.sh

  It '正常動作'

    When run efu_run sx_arg_fold res efu_cb_sum 0 1 2 3 4 5
    The status should be success
  End
End
