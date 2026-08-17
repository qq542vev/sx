Describe 'sx_str_escape -efu 環境検証'
  Include ./sx.sh

  It '正常動作'
    When run efu_run sx_str_escape res 'a\b"c' '\"'
    The status should be success
  End
End
