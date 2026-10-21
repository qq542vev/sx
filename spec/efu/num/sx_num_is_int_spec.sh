Describe 'sx_num_is_int -efu 環境検証'
  Include ./spec/support/library.sh spec/efu/num/sx_num_is_int_spec.sh sx_num_is_int

  It '正常動作'

    When run efu_run sx_num_is_int "0" "+123" "-456"
    The status should be success
  End
End
