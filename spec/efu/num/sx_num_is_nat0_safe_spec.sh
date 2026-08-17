Describe 'sx_num_is_nat0_safe -efu 環境検証'
  Include ./sx.sh

  It '正常動作'

    When run efu_run sx_num_is_nat0_safe "2147483647" "0"
    The status should be success
  End
End
