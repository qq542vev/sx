Describe 'sx_str_swapcase -efu 環境検証'
  Include ./spec/support/library.sh spec/efu/str/sx_str_swapcase_spec.sh sx_str_swapcase

  It '正常動作'
    When run efu_run sx_str_swapcase res "ABC"
    The status should be success
  End
End
