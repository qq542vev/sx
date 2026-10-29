# shellcheck disable=SC3003 # 制御文字にはPOSIX.1-2024のドル単一引用符を使用する。

Describe 'sx_str_is_c1 / __sx_str_is_c1 -efu 環境検証'
  sxtest_load ./build/modules/sx_str_is_c1.sh

  Parameters
    sx_str_is_c1
    __sx_str_is_c1
  End

  It 'C1領域のバイトのみの場合、0を返すこと'
    When run efu_run "$1" $'\200\201\204\205\231\233\237'
    The status should equal 0
  End

  It '引数がない場合、0を返すこと'
    When run efu_run "$1"
    The status should equal 0
  End

  It '空文字列が含まれる場合、1を返すこと'
    When run efu_run "$1" $'\200' '' $'\237'
    The status should equal 1
  End

  It '範囲外のバイトが混在する場合、1を返すこと'
    When run efu_run "$1" $'\200' $'\237\240'
    The status should equal 1
  End
End
