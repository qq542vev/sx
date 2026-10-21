Describe 'sx_num_is_int_fit_dec -efu 環境検証'
  Include ./spec/support/library.sh spec/efu/num/sx_num_is_int_fit_dec_spec.sh sx_num_is_int_fit_dec

  It '正常動作'

    When run efu_run sx_num_is_int_fit_dec 32 0
    The status should be success
  End
End
