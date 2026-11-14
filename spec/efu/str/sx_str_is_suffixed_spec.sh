Describe 'sx_str_is_suffixed -efu 環境検証'
  sxtest_load ./build/modules/sx_str_is_suffixed.sh

  It '正常動作'

    When run efu_run sx_str_is_suffixed "bar" "foobar" "foobazbar"
    The status should be success
  End
End
