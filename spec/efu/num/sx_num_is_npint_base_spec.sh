Describe 'sx_num_is_npint_base -efu 環境検証'
  Include ./sx.sh

  It '正常動作'

    When run efu_run sx_num_is_npint_base 10 "0" "+0" "-0" "-1" "-123"
    The status should be success
  End
End
