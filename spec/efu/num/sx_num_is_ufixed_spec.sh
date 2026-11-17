Describe 'sx_num_is_ufixed -efu 環境検証'
  sxtest_load ./build/modules/sx_num_is_ufixed.sh

  It '正常動作'

    When run efu_run sx_num_is_ufixed "1" "123" "10" "1.5" "1.0" "123.456" "0"
    The status should be success
  End
End
