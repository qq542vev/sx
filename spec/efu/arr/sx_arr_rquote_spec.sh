Describe 'sx_arr_rquote -efu 環境検証'
  Include ./spec/support/library.sh spec/efu/arr/sx_arr_rquote_spec.sh sx_arr_gen sx_arr_rquote

  It '正常動作'
sx_arr_gen arr1 a b c

    When run efu_run sx_arr_rquote result arr1
    The status should be success
  End
End
