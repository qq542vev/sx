Describe 'sx_str_rfind -efu 環境検証'
  Include ./spec/support/run.sh
  # 検証に使うフラグ定数は、対象モジュールの依存とは別に準備する。
  sxtest_run SX_STR_RFIND_GLOB SX_STR_RFIND_OVERLAP -- ''
  sxtest_load ./build/modules/sx_str_rfind.sh

  It '正常動作'

    When run efu_run sx_str_rfind res "hello world" "world"
    The status should be success
  End

  It 'glob と重複フラグの併用でもパターン文字を含むデータを正しく検索できること'
    verify_rfind() {
      sx_str_rfind res 'a*' a "$((SX_STR_RFIND_GLOB | SX_STR_RFIND_OVERLAP))"
      [ "$res" = '0:1' ]
      check_no_leak
    }
    When run efu_run verify_rfind
    The status should be success
  End
End
