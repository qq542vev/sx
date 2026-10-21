Describe 'sx_str_is_punct -efu 環境検証'
  Include ./spec/support/library.sh spec/efu/str/sx_str_is_punct_spec.sh sx_str_is_punct

  It '正常動作'

    When run efu_run sx_str_is_punct "!@#"
    The status should be success
  End
End
