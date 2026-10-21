Describe 'sx_arg_range -efu 環境検証'
  Include ./spec/support/library.sh spec/efu/arg/sx_arg_range_spec.sh sx_arg_range

  It '正常動作'

    When run efu_run sx_arg_range result 3
    The status should be success
  End
End
