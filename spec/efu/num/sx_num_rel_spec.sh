Describe 'sx_num_rel -efu 環境検証'
  Include ./spec/support/library.sh spec/efu/num/sx_num_rel_spec.sh sx_num_rel

  It '正常動作'

    When run efu_run sx_num_rel 1 '<' 2
    The status should be success
  End
End
