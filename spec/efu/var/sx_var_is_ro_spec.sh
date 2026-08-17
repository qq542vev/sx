Describe 'sx_var_is_ro -efu 環境検証'
  Include ./sx.sh

  It '正常動作'
    b_ro=1; readonly b_ro

    When run efu_run sx_var_is_ro b_ro
    The status should be success
  End
End
