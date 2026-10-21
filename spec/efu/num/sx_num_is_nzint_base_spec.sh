Describe 'sx_num_is_nzint_base -efu 環境検証'
  Include ./spec/support/library.sh spec/efu/num/sx_num_is_nzint_base_spec.sh sx_num_is_nzint_base

  It '正常動作'

    When run efu_run sx_num_is_nzint_base 10 "1" "123" "-1"
    The status should be success
  End

  It 'ゼロが含まれる場合の失敗動作'

    When run efu_run sx_num_is_nzint_base 10 "1" "0" "123"
    The status should be failure
  End
End
