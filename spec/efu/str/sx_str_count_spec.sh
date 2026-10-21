Describe 'sx_str_count -efu 環境検証'
  Include ./spec/support/library.sh sx_str_count

  It '正常動作'

    When run efu_run sx_str_count res "hello world" "world"
    The status should be success
  End
End
