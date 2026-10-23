# shellcheck disable=SC2016 # CMD内の変数は準備用シェルで展開する。
# shellcheck shell=sh disable=SC2329
# コールバックと検証用の差し替え関数は間接的に呼び出される。
Describe 'sx_arg_pad -efu 環境検証'
  Include ./spec/support/prepare.sh
  Include ./spec/support/setup.sh
  Include ./spec/support/library.sh sx_arg_pad

  It '正常動作'

    When run efu_run sx_arg_pad res 5 '_' ::: a b c
    The status should be success
  End

  Context '多倍長経路'
    Parameters
      0
      1
    End

    It '再入の結果を末尾で代入しても部分結果を保持する'
      sxtest_setup SX_CFG_SKIP_CHK -- 'sx_cfg_set "$@"' "SKIP_CHK=$1"
      __sx_num_is_int_safe_inv() { return 0; }
      __sx_num_is_int_fit_dec() { return 1; }
      __sx_num_add1_arith() { return 64; }
      __sx_num_sub1_arith() { return 64; }
      res=''
      inner_cb() { sx_test_setup sx_var_set "${1}=inner"; }
      cb() {
        sx_arg_pad nested_result 2 inner_cb 1 ::: z
        eval "${1}=\${nested_result}"
      }
      verify() {
        sx_arg_pad res 3 cb 1 ::: a
        eval "set -- $res"
        [ "$#" = 3 ] && [ "$1" = a ] && [ "$2" = "'z' 'inner'" ] && [ "$3" = "$2" ]
      }
      When run efu_run verify
      The status should be success
    End

    It '左パディングの失敗時にも元の値を結合し終了状態を返す'
      sxtest_setup SX_CFG_SKIP_CHK -- 'sx_cfg_set "$@"' "SKIP_CHK=$1"
      __sx_num_is_int_safe_inv() { return 0; }
      __sx_num_is_int_fit_dec() { return 1; }
      cb() { return 77; }
      res=''
      verify() {
        status=0
        sx_arg_pad res -3 cb 1 ::: a b || status="$?"
        [ "$res" = "'a' 'b'" ] && [ "$status" = 77 ]
      }
      When run efu_run verify
      The status should be success
    End
  End
End
