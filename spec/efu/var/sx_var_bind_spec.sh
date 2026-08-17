Describe 'sx_var_bind -efu 環境検証'
  Include ./sx.sh

  It '正常動作'

    When run efu_run sx_var_bind res "v1:v2:rest" "val1"
    The status should be success
  End
End
