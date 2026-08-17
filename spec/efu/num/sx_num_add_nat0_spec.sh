Describe 'sx_num_add_nat0 -efu 環境検証'
  Include ./sx.sh

  It '正常動作'

    When run efu_run sx_num_add_nat0 result
    The status should be success
  End
End
