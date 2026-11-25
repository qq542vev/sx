Describe 'sx_sh_param_ref -efu 環境検証'
  sxtest_load ./build/modules/sx_sh_param_ref.sh

  It '正常動作'
    When run efu_run sx_sh_param_ref res ' ' a b c
    The status should be success
  End

  It '位置パラメータ'
    When run efu_run sx_sh_param_ref res ' ' 1 2 3
    The status should be success
  End

  It '任意の区切り文字'
    When run efu_run sx_sh_param_ref res ', ' a b
    The status should be success
  End

  It '無効なパラメータ'
    When run efu_run sx_sh_param_ref res ' ' '&'
    The status should be failure
  End

  It '無効な結果変数名'
    When run efu_run sx_sh_param_ref 1res ' ' a
    The status should be failure
  End
End
