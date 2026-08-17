Describe 'sx_var_dump -efu 環境検証'
  Include ./sx.sh

  It '正常動作'

    When run efu_run sx_var_dump res v1
    The status should be success
  End
End
