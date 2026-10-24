Describe 'sx_str_is_hex -efu 環境検証'
  sxtest_load ./build/modules/sx_str_is_hex.sh

  It '正常動作'

    When run efu_run sx_str_is_hex "0123456789abcdef"
    The status should be success
  End
End
