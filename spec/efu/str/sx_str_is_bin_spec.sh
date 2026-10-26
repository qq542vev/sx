Describe '2進数字の文字列判定 -efu 環境検証'
  sxtest_load ./build/modules/sx_str_is_bin.sh

  Parameters
    sx_str_is_bin
    __sx_str_is_bin
  End

  It '2進数字のみの場合に成功すること'
    When run efu_run "$1" '0' '1' '00101'
    The status should equal 0
  End

  It '引数がない場合に成功すること'
    When run efu_run "$1"
    The status should equal 0
  End

  It '空文字列を不一致として返すこと'
    When run efu_run "$1" ''
    The status should equal 1
  End

  It '途中の引数に2進数字以外がある場合に不一致として返すこと'
    When run efu_run "$1" '01' '0b10' '10'
    The status should equal 1
  End
End
