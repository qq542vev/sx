Describe 'sx_str_is_digit -efu 環境検証'
  Include ./sx.sh

  It '正常動作'

    When run efu_run sx_str_is_digit "123" "0" "456"
    The status should be success
  End
End
