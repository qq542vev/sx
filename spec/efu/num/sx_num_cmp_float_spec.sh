Describe 'sx_num_cmp_float -efu 環境検証'
  Include ./sx.sh

  It '正常動作'
    When run efu_run sx_num_cmp_float 1.2 1.2
    The status should equal 2
  End
End
