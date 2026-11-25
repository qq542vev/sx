Describe 'sx_sh_is_pos -efu 環境検証'
  sxtest_load ./build/modules/sx_sh_is_pos.sh

  It '正常動作'
    When run efu_run sx_sh_is_pos 1 09 57 000006
    The status should be success
  End

  It '無効な位置パラメータ'
    When run efu_run sx_sh_is_pos 00 a1
    The status should be failure
  End
End
