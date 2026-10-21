Describe 'sx_num_cmp_fixed -efu 環境検証'
  Include ./spec/support/library.sh sx_num_cmp_fixed

  It '正常動作'
    When run efu_run sx_num_cmp_fixed 5 5
    The status should equal 2
  End
End
