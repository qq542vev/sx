Describe 'sx_num_is_ufloat -efu 環境検証'
  sxtest_load ./build/modules/sx_num_is_ufloat.sh

  It '正常動作'

    When run efu_run sx_num_is_ufloat "1" "123" "10" "1.5" "1.0" "1e3" "1.2e-3" "1E+5" "0e0" "0"
    The status should be success
  End
End
