Describe 'sx_num_mul_nat0 -efu 環境検証'
  Include ./spec/support/library.sh sx_num_mul_nat0

  It '正常動作'

    When run efu_run sx_num_mul_nat0 result 0 123
    The status should be success
  End
End
