Describe 'sx_str_lower -efu 環境検証'
  Include ./spec/support/library.sh sx_str_lower

  It '正常動作'
    When run efu_run sx_str_lower res "ABC"
    The status should be success
  End
End
