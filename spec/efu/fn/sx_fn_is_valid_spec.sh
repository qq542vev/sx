Describe 'sx_fn_is_valid -efu 環境検証'
  Include ./spec/support/library.sh sx_fn_is_valid

  It '正常動作'

    When run efu_run sx_fn_is_valid "f=:" "g=echo hello"
    The status should be success
  End
End
