Describe 'sx_ex_remap -efu 環境検証'
  sxtest_load ./build/modules/sx_ex_remap.sh

  It '正常動作'

    When run efu_run sx_ex_remap 1:64 ::: sh -c 'exit 1'
    The status should equal 64
  End
End
