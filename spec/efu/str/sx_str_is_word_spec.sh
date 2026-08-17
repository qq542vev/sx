Describe 'sx_str_is_word -efu 環境検証'
  Include ./sx.sh

  It '正常動作'

    When run efu_run sx_str_is_word "abc_123" "_ABC" "abc"
    The status should be success
  End
End
