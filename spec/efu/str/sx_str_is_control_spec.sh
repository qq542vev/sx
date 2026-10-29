# shellcheck disable=SC3003 # 制御文字にはPOSIX.1-2024のドル単一引用符を使用する。

Describe 'sx_str_is_control / __sx_str_is_control -efu 環境検証'
  sxtest_load ./build/modules/sx_str_is_control.sh

  Parameters
    sx_str_is_control
    __sx_str_is_control
  End

  It 'C0・C1・DELが混在していても0を返すこと'
    When run efu_run "$1" $'\001\037' $'\200\237' $'\177\205\012'
    The status should equal 0
  End

  It '引数がない場合、0を返すこと'
    When run efu_run "$1"
    The status should equal 0
  End

  It '空文字列が含まれる場合、1を返すこと'
    When run efu_run "$1" $'\001' '' $'\237'
    The status should equal 1
  End

  It '範囲外のバイトが混在する場合、1を返すこと'
    When run efu_run "$1" $'\001' $'\237\240'
    The status should equal 1
  End
End
