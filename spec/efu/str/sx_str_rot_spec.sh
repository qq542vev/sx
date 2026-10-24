Describe 'sx_str_rot -efu 環境検証'
  sxtest_load ./build/modules/sx_str_rot.sh

  It '正常動作'
    When run efu_run sx_str_rot res "HELLO" "ABCDEFGHIJKLMNOPQRSTUVWXYZ" 13
    The status should be success
  End
End
