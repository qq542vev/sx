Describe 'sx_str_rot -efu 環境検証'
  Include ./sx.sh

  It '正常動作'
    When run efu_run sx_str_rot res "HELLO" "${SX_STR_UPPER}" 13
    The status should be success
  End
End
