Describe 'sx_glob_escape -efu 環境検証'
  Include ./spec/support/library.sh spec/efu/glob/sx_glob_escape_spec.sh sx_glob_escape

  It '正常動作'
    When run efu_run sx_glob_escape result 'a*b'
    The status should be success
  End
End
