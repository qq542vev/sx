# shellcheck disable=SC3003 # 高位バイト・制御文字にはPOSIX.1-2024のドル単一引用符を使用する。

Describe 'sx_str_is_graphic / __sx_str_is_graphic -efu 環境検証'
  sxtest_load ./build/modules/sx_str_is_graphic.sh

  Parameters
    sx_str_is_graphic
    __sx_str_is_graphic
  End

  It 'ASCIIとGRが混在していても0を返すこと'
    When run efu_run "$1" $'!\240' $'~\377' "a'\\$"
    The status should equal 0
  End

  It '引数がない場合、0を返すこと'
    When run efu_run "$1"
    The status should equal 0
  End

  It '空文字列が含まれる場合、1を返すこと'
    When run efu_run "$1" 'a' '' $'\377'
    The status should equal 1
  End

  It 'ASCIIスペースが混在する場合、1を返すこと'
    When run efu_run "$1" $'! \377'
    The status should equal 1
  End

  It 'C0・C1・DELが混在する場合、1を返すこと'
    When run efu_run "$1" $'!\001\177\200\377'
    The status should equal 1
  End
End
