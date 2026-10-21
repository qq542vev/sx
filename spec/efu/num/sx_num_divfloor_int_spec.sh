Describe 'sx_num_divfloor_int -efu 環境検証'
  Include ./spec/support/library.sh spec/efu/num/sx_num_divfloor_int_spec.sh sx_num_divfloor_int

  It '正常動作'

    When run efu_run sx_num_divfloor_int q -100 3
    The status should be success
  End
End
