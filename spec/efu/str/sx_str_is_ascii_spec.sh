Describe 'sx_str_is_ascii -efu 環境検証'
  Include ./spec/support/library.sh sx_str_is_ascii

  It '正常動作'

    When run efu_run sx_str_is_ascii "abcXYZ"
    The status should be success
  End
End
