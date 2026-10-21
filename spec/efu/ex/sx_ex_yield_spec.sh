Describe 'sx_ex_yield -efu 環境検証'
  Include ./spec/support/library.sh spec/efu/ex/sx_ex_yield_spec.sh sx_ex_yield

  It '正常動作'

    When run efu_run sx_ex_yield 0
    The status should be success
  End
End
