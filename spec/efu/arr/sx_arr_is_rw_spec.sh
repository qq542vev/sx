Describe 'sx_arr_is_rw -efu 環境検証'
  Include ./sx.sh

  It '正常動作'
sx_arr_gen arr a b c

    When run efu_run sx_arr_is_rw arr 0 2
    The status should be success
  End
End
