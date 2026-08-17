Describe 'sx_num_is_int_fit_dec -efu 環境検証'
  Include ./sx.sh

  It '正常動作'

    When run efu_run sx_num_is_int_fit_dec 32 0
    The status should be success
  End
End
