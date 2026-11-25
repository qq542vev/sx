Describe 'sx_sh_is_param -efu 環境検証'
  sxtest_load ./build/modules/sx_sh_is_param.sh

  It '正常動作'
    When run efu_run sx_sh_is_param @ '*' '#' '?' '-' '$' '!' 0 5 008 aaa
    The status should be success
  End

  It '無効なパラメータ'
    When run efu_run sx_sh_is_param '&'
    The status should be failure
  End
End
