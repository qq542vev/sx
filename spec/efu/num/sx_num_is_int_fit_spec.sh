Describe 'sx_num_is_int_fit -efu 環境検証'
  Include ./sx.sh

  It '正常動作'

    When run efu_run sx_num_is_int_fit 8 "127" "-128" "0177" "-0200" "0x7F" "-0x80"
    The status should be success
  End
End
