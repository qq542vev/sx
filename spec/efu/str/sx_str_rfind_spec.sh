Describe 'sx_str_rfind -efu 環境検証'
  Include ./spec/support/library.sh spec/efu/str/sx_str_rfind_spec.sh sx_str_rfind

  It '正常動作'

    When run efu_run sx_str_rfind res "hello world" "world"
    The status should be success
  End
End
