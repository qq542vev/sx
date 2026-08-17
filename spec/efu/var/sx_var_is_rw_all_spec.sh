Describe 'sx_var_is_rw_all -efu 環境検証'
  Include ./sx.sh

  It '正常動作'

    When run efu_run sx_var_is_rw_all v1 v2
    The status should be success
  End
End
