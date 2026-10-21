Describe 'sx_str_strim -efu 環境検証'
  Include ./spec/support/library.sh spec/efu/str/sx_str_strim_spec.sh sx_str_strim

  It '正常動作'
    When run efu_run sx_str_strim res "  hello"
    The status should be success
  End
End
