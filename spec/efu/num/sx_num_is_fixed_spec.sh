Describe 'sx_num_is_fixed -efu 環境検証'
  Include ./spec/support/library.sh sx_num_is_fixed

  It '正常動作'

    When run efu_run sx_num_is_fixed "0" "123" "+456" "-789"
    The status should be success
  End
End
