Describe 'sx_var_set -efu 環境検証'
  sxtest_load ./build/modules/sx_var_set.sh

  It '正常動作'

    When run efu_run sx_var_set v1=a v2=b
    The status should be success
  End
End
