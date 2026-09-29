Describe 'sx_arr_is_spec -efu 環境検証'
  Include ./sx.sh

  It '正常動作'
    When run efu_run sx_arr_is_spec 0:5:2
    The status should be success
  End
End
