Describe 'sx_ex_is_status -efu 環境検証'
  sxtest_load ./build/modules/sx_ex_is_status.sh

  It '正常動作'

    When run efu_run sx_ex_is_status 0
    The status should be success
  End
End
