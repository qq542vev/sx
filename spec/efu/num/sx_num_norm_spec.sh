Describe 'sx_num_norm -efu 環境検証'
  Include ./spec/support/library.sh spec/efu/num/sx_num_norm_spec.sh sx_num_norm

  It '正常動作'

    When run efu_run sx_num_norm res 123
    The status should be success
  End
End
