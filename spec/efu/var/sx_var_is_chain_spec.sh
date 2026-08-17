Describe 'sx_var_is_chain -efu 環境検証'
  Include ./sx.sh

  It '正常動作'

    When run efu_run sx_var_is_chain "a-b-c"
    The status should be success
  End
End
