Describe 'sx_arr_gen -efu 環境検証'
  Include ./spec/support/library.sh sx_arr_gen

  It '正常動作'

    When run efu_run sx_arr_gen myarr "first" "second"
    The status should be success
  End
End
