Describe 'sx_str_is_of -efu 環境検証'
  sxtest_load ./build/modules/sx_str_is_of.sh

  It '正常動作'

    When run efu_run sx_str_is_of "abc" "a" "ab" "abc" "cba"
    The status should be success
  End

  It '文字集合が空で非空の文字列がある場合、1を返すこと'
    When run efu_run sx_str_is_of "" "a"
    The status should equal 1
  End

  It '文字集合と判定対象の文字列がともに空の場合、1を返すこと'
    When run efu_run sx_str_is_of "" ""
    The status should equal 1
  End

  It '文字集合が空でも判定対象の文字列がない場合、成功を返すこと'
    When run efu_run sx_str_is_of ""
    The status should be success
  End
End
