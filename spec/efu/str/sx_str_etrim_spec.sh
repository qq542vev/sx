Describe 'sx_str_etrim -efu 環境検証'
  Include ./spec/support/library.sh spec/efu/str/sx_str_etrim_spec.sh sx_str_etrim

  It '正常動作'
    When run efu_run sx_str_etrim res "hello  "
    The status should be success
  End
End
