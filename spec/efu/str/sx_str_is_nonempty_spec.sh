Describe 'sx_str_is_nonempty / __sx_str_is_nonempty -efu 環境検証'
  sxtest_load ./build/modules/sx_str_is_nonempty.sh

  Parameters
    sx_str_is_nonempty
    __sx_str_is_nonempty
  End

  It '空でない文字列の場合、0を返すこと'
    When run efu_run "$1" 'abc' '0' ' '
    The status should equal 0
  End

  It '引数がない場合、0を返すこと'
    When run efu_run "$1"
    The status should equal 0
  End

  It '空文字列が含まれる場合、1を返すこと'
    When run efu_run "$1" 'abc' '' 'def'
    The status should equal 1
  End
End
