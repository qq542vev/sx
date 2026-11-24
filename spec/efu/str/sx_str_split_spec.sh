# shellcheck disable=SC2016 # CMD内の変数は準備用シェルで展開する。
Describe 'sx_str_split -efu 環境検証'
  Include ./spec/support/run.sh
  sxtest_run SX_STR_SPLIT_GLOB SX_STR_SPLIT_ICASE SX_STR_SPLIT_EQ -- ''
  sxtest_load ./build/modules/sx_str_split.sh

  Context '多倍長の回数と直接バインド'
    Parameters
      0 abc '' 999999999999999999999999 0
      1 abc '' 999999999999999999999999 2
      0 abc '' -9223372036854775808 0
      1 abc '' -999999999999999999999999 2
      0 abc '' -2 2
      1 abc '**' '' 3
      0 'a:b:c' : 999999999999999999999999 2
      1 a1b2c '[0-9]' -999999999999999999999999 3
      0 abc '' -0 2
    End

    It '検査の有無によらず-efu下で成功すること'
      sxtest_run SX_CFG_SKIP_CHK -- 'sx_cfg_set "$@"' "SKIP_CHK=$1"
      When run efu_run sx_str_split 'a:b:rem' "$2" "$3" "$4" "$5"
      The status should be success
    End
  End

  It '正常動作'

    When run efu_run sx_str_split "a:b:rem" "v1:v2:v3:v4" ":"
    The status should be success
  End

  It 'ICASE と EQ フラグでも -efu 下で正常動作すること'
    verify_icase_eqc() {
      sx_str_split res "a1B2b3" "b" "" "$SX_STR_SPLIT_ICASE"
      [ "$res" = "'a1' '2' '3'" ] || return 1
      sx_str_split res "a1b2a3" "a" "" "$SX_STR_SPLIT_EQ"
      [ "$res" = "'' '1b2' '3'" ] || return 1
      check_no_leak
    }
    When run efu_run verify_icase_eqc
    The status should be success
  End
End
