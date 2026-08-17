Describe 'sx_str_is_oct -efu 環境検証'
  Include ./sx.sh

  It '正常動作'

    When run efu_run sx_str_is_oct "01234567"
    The status should be success
  End
End
