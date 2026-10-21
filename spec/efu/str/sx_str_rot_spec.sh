Describe 'sx_str_rot -efu 環境検証'
  Include ./spec/support/library.sh sx_str_rot

  It '正常動作'
    When run efu_run sx_str_rot res "HELLO" "ABCDEFGHIJKLMNOPQRSTUVWXYZ" 13
    The status should be success
  End
End
