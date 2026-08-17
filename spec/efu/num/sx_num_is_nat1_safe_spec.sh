Describe 'sx_num_is_nat1_safe -efu 環境検証'
  Include ./sx.sh

  It '正常動作'

    When run efu_run sx_num_is_nat1_safe "2147483647" "1"
    The status should be success
  End
End
