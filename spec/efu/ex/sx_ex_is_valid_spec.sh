Describe 'sx_ex_is_valid -efu 環境検証'
  Include ./spec/support/library.sh sx_ex_is_valid

  It '正常動作'

    When run efu_run sx_ex_is_valid 0
    The status should be success
  End
End
