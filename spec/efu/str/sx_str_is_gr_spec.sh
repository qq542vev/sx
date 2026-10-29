# shellcheck disable=SC3003 # 高位バイトにはPOSIX.1-2024のドル単一引用符を使用する。

Describe 'sx_str_is_gr / __sx_str_is_gr -efu 環境検証'
  sxtest_load ./build/modules/sx_str_is_gr.sh

  Parameters
    sx_str_is_gr
    __sx_str_is_gr
  End

  It 'GR領域のバイトのみの場合、0を返すこと'
    When run efu_run "$1" $'\240\255\300\376\377'
    The status should equal 0
  End

  It '引数がない場合、0を返すこと'
    When run efu_run "$1"
    The status should equal 0
  End

  It '空文字列が含まれる場合、1を返すこと'
    When run efu_run "$1" $'\240' '' $'\377'
    The status should equal 1
  End

  It '範囲外のバイトが混在する場合、1を返すこと'
    When run efu_run "$1" $'\240' $'\377\237'
    The status should equal 1
  End
End
