Describe 'sx_arr_is_spec -efu 環境検証'
  Include ./spec/support/library.sh spec/efu/arr/sx_arr_is_spec_spec.sh sx_arr_is_spec

  It '正常動作'
    When run efu_run sx_arr_is_spec 0:5:2
    The status should be success
  End
End
