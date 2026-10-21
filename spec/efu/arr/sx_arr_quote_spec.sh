Describe 'sx_arr_quote -efu 環境検証'
  Include ./spec/support/library.sh spec/efu/arr/sx_arr_quote_spec.sh sx_arr_gen sx_arr_quote

  It '正常動作'
sx_arr_gen arr1 a b c

    When run efu_run sx_arr_quote result arr1
    The status should be success
  End
End
