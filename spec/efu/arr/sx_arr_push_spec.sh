Describe 'sx_arr_push -efu 環境検証'
  Include ./spec/support/library.sh spec/efu/arr/sx_arr_push_spec.sh sx_arr_gen sx_arr_push

  It '正常動作'
sx_arr_gen myarr a b c

    When run efu_run sx_arr_push myarr b c
    The status should be success
  End
End
