Describe 'sx_sh_pos_ref -efu 環境検証'
  sxtest_load ./build/modules/sx_sh_pos_ref.sh

  It '正常動作'

    When run efu_run sx_sh_pos_ref result ' ' -3:4
    The status should be success
  End
End
