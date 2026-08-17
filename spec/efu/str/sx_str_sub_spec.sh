Describe 'sx_str_sub -efu 環境検証'
  Include ./sx.sh

  It '正常動作'

    When run efu_run sx_str_sub result "hello world" "world" "earth"
    The status should be success
  End
End
