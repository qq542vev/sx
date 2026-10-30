# shellcheck disable=SC3003 # 制御文字にはPOSIX.1-2024のドル単一引用符を使用する。

Describe 'sx_str_is_c0 / __sx_str_is_c0 -efu 環境検証'
  sxtest_load ./build/modules/sx_str_is_c0.sh

  Parameters
    sx_str_is_c0
    __sx_str_is_c0
  End

  It 'C0領域のみの場合、0を返すこと'
    When run efu_run "$1" $'\001\011\012\015\037'
    The status should equal 0
  End

  It '引数がない場合、0を返すこと'
    When run efu_run "$1"
    The status should equal 0
  End

  It '空文字列が含まれる場合、1を返すこと'
    When run efu_run "$1" $'\001' '' $'\037'
    The status should equal 1
  End

  It 'DELが混在する場合、1を返すこと'
    When run efu_run "$1" $'\001' $'\037\177'
    The status should equal 1
  End
End
