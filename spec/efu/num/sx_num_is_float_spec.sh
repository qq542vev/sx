Describe 'sx_num_is_float -efu 環境検証'
  Include ./spec/support/library.sh spec/efu/num/sx_num_is_float_spec.sh sx_num_is_float

  It '正常動作'

    When run efu_run sx_num_is_float "0" "123" "-0.5" "1.00000000000"
    The status should be success
  End
End
