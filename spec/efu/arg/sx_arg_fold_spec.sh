# shellcheck disable=SC2016 # CMD内の変数は準備用シェルで展開する。
# shellcheck shell=sh disable=SC2329
# コールバックと検証用の差し替え関数はShellSpec経由で間接的に呼び出される。

Describe 'sx_arg_fold -efu 環境検証'
  Include ./spec/support/run.sh
  Include ./spec/support/library.sh sx_arg_fold

  # 再入する対象関数は同じシェル内で呼び、補助代入だけを分離する。
  cb_sum() { sxtest_run "${1}" -- 'sx_var_set "$@"' "${1}=$((${2} + ${3}))"; }

  Context '多倍長経路'
    Parameters
      0
      1
    End

    It '検証の有無によらず-efu下で全要素を畳み込む'
      sxtest_run SX_CFG_SKIP_CHK -- 'sx_cfg_set "$@"' "SKIP_CHK=$1"
      __sx_num_is_int_fit_dec() { return 1; }
      __sx_num_add1_arith() { return 64; }
      When run efu_run sx_arg_fold res cb_sum 0 1 2 3
      The status should be success
    End

    It '-efu下でコールバックの失敗ステータスを返す'
      sxtest_run SX_CFG_SKIP_CHK -- 'sx_cfg_set "$@"' "SKIP_CHK=$1"
      __sx_num_is_int_fit_dec() { return 1; }
      __sx_num_add1_arith() { return 64; }
      cb() {
        case "$4" in 2) return 77;; esac
        sxtest_run "${1}" -- 'sx_var_set "$@"' "${1}=${2}${3}"
      }
      When run efu_run sx_arg_fold res cb init a b c
      The status should equal 77
    End

    It '-efu下で結果変数への再入呼び出しを扱う'
      sxtest_run SX_CFG_SKIP_CHK -- 'sx_cfg_set "$@"' "SKIP_CHK=$1"
      __sx_num_is_int_fit_dec() { return 1; }
      __sx_num_add1_arith() { return 64; }
      inner_cb() { sxtest_run "${1}" -- 'sx_var_set "$@"' "${1}=${2}${3}"; }
      outer_cb() { sx_arg_fold "$1" inner_cb "$2" "$3" x; }
      When run efu_run sx_arg_fold res outer_cb init a b
      The status should be success
    End
  End

  It '空リストでは直前の失敗状態を引き継がない'
    sxtest_run SX_CFG_SKIP_CHK -- 'sx_cfg_set "$@"' SKIP_CHK=1
    fail() { return 77; }
    after_failure() { fail || sx_arg_fold res efu_cb_true init; }
    When run efu_run after_failure
    The status should be success
  End

  It '正常動作'

    When run efu_run sx_arg_fold res cb_sum 0 1 2 3 4 5
    The status should be success
  End
End
