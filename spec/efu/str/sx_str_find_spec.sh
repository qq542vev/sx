Describe 'sx_str_find -efu 環境検証'
  Include ./spec/support/run.sh
  # 検証に使うフラグ定数は、対象モジュールの依存とは別に準備する。
  sxtest_run SX_STR_FIND_TEXT SX_STR_FIND_POS SX_STR_FIND_LEN SX_STR_FIND_ICASE SX_STR_FIND_EQC -- ''
  sxtest_load ./build/modules/sx_str_find.sh

  It '正常動作'

    When run efu_run sx_str_find res "hello world" "world"
    The status should be success
  End

  It 'ICASE と EQC フラグでも -efu 下で正常動作すること'
    verify_icase_eqc() {
      sx_str_find res "Hello World" "hello" "$SX_STR_FIND_ICASE"
      [ "$res" = "0:5" ] || return 1
      sx_str_find res "hello world" "hello" "$SX_STR_FIND_EQC"
      [ "$res" = "0:5" ] || return 1
      check_no_leak
    }
    When run efu_run verify_icase_eqc
    The status should be success
  End

  It '出力形式フラグを指定しても -efu 下で動作すること'
    verify() {
      sx_str_find res 'a_b_c' '_' "$((SX_STR_FIND_POS | SX_STR_FIND_LEN | SX_STR_FIND_TEXT))"
      [ "$res" = "'1:1:_' '3:1:_'" ] || return 1
      check_no_leak
    }
    When run efu_run verify
    The status should be success
  End
End
