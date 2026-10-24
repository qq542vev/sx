Describe 'sx_var_is_bind -efu 環境検証'
  sxtest_load ./build/modules/sx_var_is_bind.sh

  It '正常動作'

    When run efu_run sx_var_is_bind "a:b:c"
    The status should be success
  End
End
