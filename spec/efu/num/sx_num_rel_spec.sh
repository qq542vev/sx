Describe 'sx_num_rel -efu 環境検証'
  sxtest_load ./build/modules/sx_num_rel.sh

  It '正常動作'

    When run efu_run sx_num_rel 1 '<' 2
    The status should be success
  End
End
