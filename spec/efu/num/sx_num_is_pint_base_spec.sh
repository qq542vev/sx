Describe 'sx_num_is_pint_base -efu 環境検証'
  Include ./spec/support/library.sh spec/efu/num/sx_num_is_pint_base_spec.sh sx_num_is_pint_base

  It '正常動作'

    When run efu_run sx_num_is_pint_base 10 "1" "+123"
    The status should be success
  End
End
