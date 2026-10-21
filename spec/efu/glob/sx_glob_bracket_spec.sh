Describe 'sx_glob_bracket -efu 環境検証'
  Include ./spec/support/library.sh sx_glob_bracket

  It '正常動作'
    When run efu_run sx_glob_bracket result 'a'
    The status should be success
  End
End
