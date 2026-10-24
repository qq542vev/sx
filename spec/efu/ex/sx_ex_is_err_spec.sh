Describe 'sx_ex_is_err -efu 環境検証'
  sxtest_load ./build/modules/sx_ex_is_err.sh

  It '正常動作'

    When run efu_run sx_ex_is_err 1
    The status should be success
  End
End
