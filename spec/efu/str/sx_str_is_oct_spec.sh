Describe 'sx_str_is_oct -efu 環境検証'
  Include ./spec/support/library.sh spec/efu/str/sx_str_is_oct_spec.sh sx_str_is_oct

  It '正常動作'

    When run efu_run sx_str_is_oct "01234567"
    The status should be success
  End
End
