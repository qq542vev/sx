Describe 'sx_ex_is_err -efu 環境検証'
  Include ./spec/support/library.sh spec/efu/ex/sx_ex_is_err_spec.sh sx_ex_is_err

  It '正常動作'

    When run efu_run sx_ex_is_err 1
    The status should be success
  End
End
