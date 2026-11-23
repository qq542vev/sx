# shellcheck disable=SC2016 # CMD内の変数は準備用シェルで展開する。
# shellcheck shell=sh disable=SC2329
# コールバックと検証用の差し替え関数は間接的に呼び出される。
Describe 'sx_arg_rfind -efu 環境検証'
  Include ./spec/support/run.sh
  # 検証に使うフラグ定数は、対象モジュールの依存とは別に準備する。
  sxtest_run SX_ARG_FIND_POS SX_ARG_RFIND_POS SX_ARG_RFIND_TEXT SX_ARG_RFIND_CB SX_ARG_RFIND_ICASE SX_ARG_RFIND_EQC -- ''
  sxtest_load ./build/modules/sx_arg_rfind.sh

  It '正常動作'

    When run efu_run sx_arg_rfind res "b" ::: "a" "b" "c"
    The status should be success
  End

  It '出力形式フラグを指定しても -efu 下で動作すること'
    verify() {
      sx_arg_rfind res 'b' "$((SX_ARG_RFIND_POS | SX_ARG_RFIND_TEXT))" ::: a b c b
      [ "$res" = "'4:b' '2:b'" ] || return 1
      check_no_leak
    }
    When run efu_run verify
    The status should be success
  End

  It 'ICASE / EQC を -efu 下で使用でき変数漏洩がないこと'
    verify() {
      sx_arg_rfind res 'cafe' "$SX_ARG_RFIND_ICASE" ::: 'CAFE' 'cafe'
      [ "$res" = '2 1' ] || return 1
      LC_ALL=C
      sx_arg_rfind res2 'cafe' "$SX_ARG_RFIND_EQC" ::: 'cafe' 'CAFE'
      [ "$res2" = '1' ] || return 1
      check_no_leak
    }
    When run efu_run verify
    The status should be success
  End

  It 'CB と POS|TEXT の併用で再入と変数漏洩がないこと'
    verify() {
      cb() {
        sx_arg_rfind nested y "$((SX_ARG_RFIND_POS | SX_ARG_RFIND_TEXT))" ::: x y
        case "$1" in b) return 0;; esac
        return 77
      }
      sx_arg_rfind res cb "$((SX_ARG_RFIND_CB | SX_ARG_RFIND_POS | SX_ARG_RFIND_TEXT))" ::: a b c b
      [ "$res" = "'4:b' '2:b'" ] && [ "$nested" = "'2:y'" ] || return 1
      check_no_leak
    }
    When run efu_run verify
    The status should be success
  End

  Context '多倍長経路'
    Parameters
      0
      1
    End

    It '再入とバインド枯渇時も状態を保持する'
      sxtest_run SX_CFG_SKIP_CHK -- 'sx_cfg_set "$@"' "SKIP_CHK=$1"
      __sx_num_is_nat0_safe() { return 0; }
      __sx_num_is_int_fit_dec() { return 1; }
      __sx_num_sub1_arith() { return 64; }
      __sx_num_add1_arith() { return 64; }
      calls='' res='' nested_result=''
      inner_cb() { return 0; }
      cb() {
        sx_arg_rfind nested_result inner_cb 2 ::: x y
        calls="${calls}${2}:${3};"
        case "$1" in b) return 0;; esac
        return 77
      }
      verify() {
        sx_arg_rfind '2res:' cb 2 ::: a b c b
        [ "$res" = '4 2' ] && [ "$nested_result" = '2 1' ] && [ "$calls" = '4:0;3:1;2:1;' ]
      }
      When run efu_run verify
      The status should be success
    End

    It '全件不一致なら終了状態1を返す'
      sxtest_run SX_CFG_SKIP_CHK -- 'sx_cfg_set "$@"' "SKIP_CHK=$1"
      __sx_num_is_nat0_safe() { return 0; }
      __sx_num_is_int_fit_dec() { return 1; }
      cb() { return 77; }
      When run efu_run sx_arg_rfind res cb 2 ::: a b
      The status should equal 1
    End

    It 'NOT 指定でも再入時に状態を保持する'
      sxtest_run SX_CFG_SKIP_CHK -- 'sx_cfg_set "$@"' "SKIP_CHK=$1"
      __sx_num_is_nat0_safe() { return 0; }
      __sx_num_is_int_fit_dec() { return 1; }
      __sx_num_sub1_arith() { return 64; }
      __sx_num_add1_arith() { return 64; }
      res='' nested_result=''
      inner_cb() { return 0; }
      cb() {
        sx_arg_rfind nested_result inner_cb 2 ::: x y
        case "$1" in b) return 0;; esac
        return 77
      }
      verify() {
        sx_arg_rfind '2res:' cb 10 ::: a b c b
        [ "$res" = '3 1' ] && [ "$nested_result" = '2 1' ]
      }
      When run efu_run verify
      The status should be success
    End
  End
End
