Describe 'sx_str_substr -efu 環境検証'
  Include ./sx.sh

  It '正常動作'
    When run efu_run sx_str_substr res "abcdef" 2 3
    The status should be success
  End
End
