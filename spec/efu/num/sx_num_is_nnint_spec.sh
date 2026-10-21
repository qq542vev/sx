Describe 'sx_num_is_nnint -efu 環境検証'
  Include ./spec/support/library.sh spec/efu/num/sx_num_is_nnint_spec.sh sx_num_is_nnint

  It '正常動作'

    When run efu_run sx_num_is_nnint "0" "1" "07" "0xABC"
    The status should be success
  End
End
