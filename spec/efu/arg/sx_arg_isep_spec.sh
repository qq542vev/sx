# shellcheck disable=SC2016 # CMD内の変数は準備用シェルで展開する。
# shellcheck shell=sh disable=SC2329
# コールバックと経路検証用の差し替え関数は間接的に呼び出される。
Describe 'sx_arg_isep -efu 環境検証'
  Include ./spec/support/run.sh
  Include ./spec/support/library.sh sx_arg_isep

  It '正常動作'

    When run efu_run sx_arg_isep res "-" 1 ::: "a" "b" "c"
    The status should be success
  End

  Context '多倍長経路'
    Parameters:matrix
      0 1
      1 -1
    End

    It '未設定の結果があっても元の値と次の挿入位置を保持する'
      sxtest_run SX_CFG_SKIP_CHK -- 'sx_cfg_set "$@"' "SKIP_CHK=$1"
      direction="$2" res=''
      __sx_num_is_nat0_safe() { return 0; }
      __sx_num_is_int_fit_dec() { case "$#" in 2) return 0;; *) return 1;; esac; }
      __sx_num_add1_arith() { return 64; }
      __sx_num_sub1_arith() { return 64; }
      cb() { case "$3" in 2) sxtest_run "${1}" -- 'sx_var_set "$@"' "${1}=${2}:${3}:${4}";; *) unset "$1";; esac; }
      verify() {
        sx_arg_isep res cb "$direction" '' 7 ::: a b
        [ "$res" = "'a' '1:2:1' 'b'" ] && check_no_leak
      }
      When run efu_run verify
      The status should be success
    End

    It 'コールバックの失敗時にも元の値を保持して変数を解放する'
      sxtest_run SX_CFG_SKIP_CHK -- 'sx_cfg_set "$@"' "SKIP_CHK=$1"
      direction="$2" res=''
      cb() { sxtest_run "${1}" -- 'sx_var_set "$@"' "${1}=discard"; return 77; }
      verify() {
        status=0
        sx_arg_isep res cb "$direction" 9223372036854775808 7 ::: a b || status="$?"
        [ "$status" = 77 ] && [ "$res" = "'a' 'b'" ] && check_no_leak
      }
      When run efu_run verify
      The status should be success
    End

    It '再入呼び出しが算術経路を選んでも外側の状態を保持する'
      sxtest_run SX_CFG_SKIP_CHK -- 'sx_cfg_set "$@"' "SKIP_CHK=$1"
      direction="$2" res=''
      inner_cb() { sxtest_run "${1}" -- 'sx_var_set "$@"' "${1}=inner"; }
      cb() {
        sx_arg_isep nested_result inner_cb 1 '' 1 ::: x y
        eval "${1}=\${nested_result}"
      }
      verify() {
        sx_arg_isep res cb "$direction" 9223372036854775808 7 ::: a b
        eval "set -- $res"
        [ "$#" = 5 ] && [ "$1" = "'x' 'inner' 'y'" ] && [ "$2" = a ] &&
          [ "$3" = "$1" ] && [ "$4" = b ] && [ "$5" = "$1" ] && check_no_leak
      }
      When run efu_run verify
      The status should be success
    End
  End
End
