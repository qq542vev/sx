Describe 'sx_str_isep -efu 環境検証'
  sxtest_load ./build/modules/sx_str_isep.sh

  It '正常動作'

    When run efu_run sx_str_isep res: "123456" "-" 2
    The status should be success
  End

  It 'コールバックが再入呼び出しの結果を直接返せること'
    leaf() { eval "${1}=X"; }
    nested() { sx_str_isep "${1}:" ab leaf 1 '' 1; }
    verify_nested() {
      sx_str_isep res:cnt abc nested 1 '' 1
      [ "$res" = 'aaXbbaXbc' ]
      [ "$cnt" = "'2'" ]
      check_no_leak
    }
    When run efu_run verify_nested
    The status should be success
  End
End
