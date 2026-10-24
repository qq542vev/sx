Describe 'sx_num_mul_nat0 -efu 環境検証'
  sxtest_load ./build/modules/sx_num_mul_nat0.sh

  It '正常動作'

    When run efu_run sx_num_mul_nat0 result 0 123
    The status should be success
  End
End
