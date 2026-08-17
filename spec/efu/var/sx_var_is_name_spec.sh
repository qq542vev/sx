Describe 'sx_var_is_name -efu 環境検証'
  Include ./sx.sh

  It '正常動作'

    When run efu_run sx_var_is_name var1 _var VAR_123
    The status should be success
  End
End
