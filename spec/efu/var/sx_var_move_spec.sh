Describe 'sx_var_move -efu 環境検証'
  Include ./spec/support/library.sh sx_var_move

  It '正常動作'

    When run efu_run sx_var_move v1-v2-v3
    The status should be success
  End
End
