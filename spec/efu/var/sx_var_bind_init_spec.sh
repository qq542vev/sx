Describe 'sx_var_bind_init -efu 環境検証'
  Include ./sx.sh

  It '正常動作'

    When run efu_run sx_var_bind_init "v1:v2:v3:v4"
    The status should be success
  End
End
