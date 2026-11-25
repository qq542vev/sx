Describe 'sx_num_is_range_spec -efu 環境検証'
  sxtest_load ./build/modules/sx_num_is_range_spec.sh

  It '正常動作'
    When run efu_run sx_num_is_range_spec 0:5:2
    The status should be success
  End
End
