Describe 'sx_str_is_hex -efu 環境検証'
  Include ./sx.sh

  It '正常動作'

    When run efu_run sx_str_is_hex "0123456789abcdef"
    The status should be success
  End
End
