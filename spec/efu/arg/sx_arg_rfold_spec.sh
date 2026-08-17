Describe 'sx_arg_rfold -efu 環境検証'
  Include ./sx.sh

  It '正常動作'

    When run efu_run sx_arg_rfold res efu_cb_set2 "" a b c
    The status should be success
  End
End
