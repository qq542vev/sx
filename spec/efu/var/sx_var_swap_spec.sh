Describe 'sx_var_swap -efu 環境検証'
  Include ./sx.sh

  It '正常動作'

    When run efu_run sx_var_swap v1-v2-v3
    The status should be success
  End
End
