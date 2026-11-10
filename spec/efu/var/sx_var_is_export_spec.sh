Describe 'sx_var_is_export -efu 環境検証'
  sxtest_load ./build/modules/sx_var_is_export.sh

  It '正常動作'
    b_exp=1; export b_exp

    When run efu_run sx_var_is_export b_exp
    The status should be success
  End
End
