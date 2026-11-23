Describe 'sx_str_count -efu 環境検証'
  Include ./spec/support/run.sh
  sxtest_run SX_STR_COUNT_ICASE SX_STR_COUNT_EQC -- ''
  sxtest_load ./build/modules/sx_str_count.sh

  It '正常動作'

    When run efu_run sx_str_count res "hello world" "world"
    The status should be success
  End

  It 'ICASE と EQC フラグでも -efu 下で正常動作すること'
    verify_icase_eqc() {
      sx_str_count res "Hello World" "hello" "$SX_STR_COUNT_ICASE"
      [ "$res" = 1 ] || return 1
      sx_str_count res "hello world" "hello" "$SX_STR_COUNT_EQC"
      [ "$res" = 1 ] || return 1
      check_no_leak
    }
    When run efu_run verify_icase_eqc
    The status should be success
  End

  Parameters
    ''
    '***'
  End

  It '空検索とアスタリスクのみのglobが-efu下で境界数を返すこと'
    When run efu_run sx_str_count res 'a*b**c' "$1" 7
    The status should be success
  End
End
