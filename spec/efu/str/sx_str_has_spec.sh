Describe 'sx_str_has -efu 環境検証'
  Include ./spec/support/library.sh spec/efu/str/sx_str_has_spec.sh sx_str_has

  It '正常動作'

    When run efu_run sx_str_has "hello world" "world"
    The status should be success
  End
End
