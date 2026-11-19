Describe 'sx_num_is_npint_base8or10 -efu 環境検証'
  sxtest_load ./build/modules/sx_num_is_npint_base8or10.sh

  It '正常動作'

    When run efu_run sx_num_is_npint_base8or10 0 -1
    The status should be success
  End

End
