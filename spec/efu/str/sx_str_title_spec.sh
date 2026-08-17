Describe 'sx_str_title -efu 環境検証'
  Include ./sx.sh

  It '正常動作'
    When run efu_run sx_str_title res "aaa bbb ccc"
    The status should be success
  End
End
