Describe 'sx_str_is_nonascii / __sx_str_is_nonascii -efu 環境検証'
  sxtest_load ./build/modules/sx_str_is_nonascii.sh

  Parameters
    sx_str_is_nonascii
    __sx_str_is_nonascii
  End

  It '非ASCII文字だけの場合、0を返すこと'
    When run efu_run "$1" '日本語' 'é😀'
    The status should equal 0
  End

  It '引数がない場合、0を返すこと'
    When run efu_run "$1"
    The status should equal 0
  End

  It '空文字列が含まれる場合、1を返すこと'
    When run efu_run "$1" 'あ' '' 'い'
    The status should equal 1
  End

  It 'ASCII文字が混在する場合、1を返すこと'
    When run efu_run "$1" 'あ' 'いaう'
    The status should equal 1
  End
End
