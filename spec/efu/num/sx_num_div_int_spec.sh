Describe 'sx_num_div_int -efu 環境検証'
  Include ./spec/support/library.sh sx_num_div_int

  It '正常動作'

    When run efu_run sx_num_div_int d 2 100 3
    The status should be success
  End
End
