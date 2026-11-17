Describe 'sx_num_is_npint_base16 -efu 環境検証'
  sxtest_load ./build/modules/sx_num_is_npint_base16.sh

  It '正常動作'

    When run efu_run sx_num_is_npint_base16 "0x0"
    The status should be success
  End
End
