Describe 'sx_fn_is_valid -efu 環境検証'
  sxtest_load ./build/modules/sx_fn_is_valid.sh

  It '正常動作'

    When run efu_run sx_fn_is_valid "f=:" "g=echo hello"
    The status should be success
  End
End
