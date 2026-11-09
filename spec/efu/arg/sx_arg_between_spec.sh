Describe 'sx_arg_between -efu 環境検証'
  sxtest_load ./build/modules/sx_arg_between.sh

  It '正常動作'
    When run efu_run sx_arg_between 1 3 "v1" "v2"
    The status should be success
  End

  It '範囲外を1で返す'
    When run efu_run sx_arg_between 3 5 "v1" "v2"
    The status should equal 1
  End

  It '不正な境界を64で返す'
    When run efu_run sx_arg_between 3 2 "v1" "v2"
    The status should equal 64
  End
End
