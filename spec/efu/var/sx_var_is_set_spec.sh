Describe 'sx_var_is_set -efu 環境検証'
  Include ./sx.sh

  It '正常動作'
    a=1 b=2

    When run efu_run sx_var_is_set a b
    The status should be success
  End
End
