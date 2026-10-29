# shellcheck disable=SC3003 # バイト値にはPOSIX.1-2024のドル単一引用符を使用する。

Describe 'sx_str_is_byte / __sx_str_is_byte -efu 環境検証'
  sxtest_load ./build/modules/sx_str_is_byte.sh

  Parameters
    sx_str_is_byte
    __sx_str_is_byte
  End

  It 'すべての領域が混在していても0を返すこと'
    When run efu_run "$1" $'\001a\177' $'\200 \237' $'\240~\377'
    The status should equal 0
  End

  It '引数がない場合、0を返すこと'
    When run efu_run "$1"
    The status should equal 0
  End

  It '空文字列の場合、1を返すこと'
    When run efu_run "$1" ''
    The status should equal 1
  End

  It '複数の引数に空文字列が含まれる場合、1を返すこと'
    When run efu_run "$1" 'a' '' $'\377'
    The status should equal 1
  End
End
