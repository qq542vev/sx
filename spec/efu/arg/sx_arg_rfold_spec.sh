# shellcheck disable=SC2016 # CMD内の変数は準備用シェルで展開する。
# shellcheck shell=sh disable=SC2329
# コールバックと検証用の差し替え関数は間接的に呼び出される。
Describe 'sx_arg_rfold -efu 環境検証'
  Include ./spec/support/run.sh

  # 共通コールバックと同じ引数を使い、補助代入だけを分離する。
  efu_cb_set2() { sxtest_run "${1}" -- 'sx_var_set "$@"' "${1}=${2}"; }
  Include ./spec/support/library.sh sx_arg_rfold

  It '正常動作'

    When run efu_run sx_arg_rfold res efu_cb_set2 "" a b c
    The status should be success
  End

  Context '多倍長経路'
    Parameters
      0
      1
    End

    It '結果変数への再入でも逆順の添字と値を保持する'
      sxtest_run SX_CFG_SKIP_CHK -- 'sx_cfg_set "$@"' "SKIP_CHK=$1"
      __sx_num_is_int_fit_dec() { return 1; }
      __sx_num_sub1_arith() { return 64; }
      inner_cb() { sxtest_run "${1}" -- 'sx_var_set "$@"' "${1}=${2}[${4}:${3}]"; }
      cb() { sx_arg_rfold "$1" inner_cb "${2}|${4}" "$3"; }
      res=''
      verify() {
        sx_arg_rfold res cb init 'a b' '' "c'd"
        [ "$res" = "init|3[1:c'd]|2[1:]|1[1:a b]" ]
      }
      When run efu_run verify
      The status should be success
    End

    It '非0のコールバック終了状態をそのまま返す'
      sxtest_run SX_CFG_SKIP_CHK -- 'sx_cfg_set "$@"' "SKIP_CHK=$1"
      __sx_num_is_int_fit_dec() { return 1; }
      cb() { sxtest_run "${1}" -- 'sx_var_set "$@"' "${1}=discard"; return 77; }
      When run efu_run sx_arg_rfold res cb init a b
      The status should equal 77
    End

    It '空リストでは数値経路を判定せず初期値を返す'
      sxtest_run SX_CFG_SKIP_CHK -- 'sx_cfg_set "$@"' "SKIP_CHK=$1"
      __sx_num_is_int_fit_dec() { return 64; }
      res=''
      verify() {
        sx_arg_rfold res cb 'init value'
        [ "$res" = 'init value' ]
      }
      When run efu_run verify
      The status should be success
    End
  End
End
