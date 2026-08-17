Describe 'sx_num_is_float_safe -efu 環境検証'
  Include ./sx.sh

  It '正常動作'

    When run efu_run sx_num_is_float_safe "0" "123" "-0.5" "1.00000000000"
    The status should be success
  End
End
