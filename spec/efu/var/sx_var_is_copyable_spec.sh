Describe 'sx_var_is_copyable -efu 環境検証'
  sxtest_load ./build/modules/sx_var_is_copyable.sh

  It '正常動作'

    When run efu_run sx_var_is_copyable "v1-v2-v3"
    The status should be success
  End
End
