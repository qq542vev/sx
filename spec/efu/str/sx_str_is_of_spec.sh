Describe 'sx_str_is_of -efu 環境検証'
  Include ./sx.sh

  It '正常動作'

    When run efu_run sx_str_is_of "abc" "a" "ab" "abc" "cba"
    The status should be success
  End
End
