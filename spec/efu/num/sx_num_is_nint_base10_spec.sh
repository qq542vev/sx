Describe 'sx_num_is_nint_base10 -efu 環境検証'
  sxtest_load ./build/modules/sx_num_is_nint_base10.sh

  It '正常動作'

    When run efu_run sx_num_is_nint_base10 "-1"
    The status should be success
  End
End
