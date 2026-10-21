Describe 'sx_str_is_space -efu 環境検証'
  Include ./spec/support/library.sh spec/efu/str/sx_str_is_space_spec.sh sx_str_is_space

  It '正常動作'

    When run efu_run sx_str_is_space "   "
    The status should be success
  End
End
