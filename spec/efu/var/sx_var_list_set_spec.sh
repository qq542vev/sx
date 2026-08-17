Describe 'sx_var_list_set -efu 環境検証'
  Include ./sx.sh

  It '正常動作'

    When run efu_run sx_var_list_set res
    The status should be success
  End
End
