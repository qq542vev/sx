Describe 'sx_num_is_num_safe -efu 環境検証'
  Include ./spec/support/library.sh sx_num_is_num_safe

  It '正常動作'

    When run efu_run sx_num_is_num_safe "0" "123" "-456"
    The status should be success
  End
End
