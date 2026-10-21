Describe 'sx_arg_len -efu 環境検証'
  Include ./spec/support/library.sh spec/efu/arg/sx_arg_len_spec.sh sx_arg_len

  It '正常動作'

    When run efu_run sx_arg_len res "v1" "v2" "v3"
    The status should be success
  End
End
