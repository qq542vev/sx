Describe 'sx_num_is_npint -efu 環境検証'
  Include ./sx.sh

  It '正常動作'

    When run efu_run sx_num_is_npint "0" "-1" "-07" "-0xABC"
    The status should be success
  End
End
