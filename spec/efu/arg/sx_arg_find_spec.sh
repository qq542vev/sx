# shellcheck disable=SC2016 # CMD内の変数は準備用シェルで展開する。
# shellcheck shell=sh disable=SC2329
# コールバックは検索関数から間接的に呼び出される。
Describe 'sx_arg_find -efu 環境検証'
  Include ./spec/support/run.sh
  Include ./spec/support/library.sh sx_arg_find

  It '正常動作'

    When run efu_run sx_arg_find res "b" ::: "a" "b" "c"
    The status should be success
  End

  It '不正な bind をシェルエラーにせず64で拒否する'
    When run efu_run sx_arg_find 'a b' target ::: target
    The status should equal 64
  End

  It 'SEP なしでは第2引数を検索対象にする'
    When run efu_run sx_arg_find res b a b
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
      __sx_num_add1_arith() { return 64; }
      calls='' res='' nested_result=''
      inner_cb() { return 0; }
      cb() {
        sx_arg_find nested_result inner_cb 2 ::: x y
        calls="${calls}${2}:${3};"
        case "$1" in b) return 0;; esac
        return 77
      }
      verify() {
        sx_arg_find '2res:' cb 2 ::: a b c b d
        [ "$res" = '2 4' ] && [ "$nested_result" = '1 2' ] && [ "$calls" = '1:0;2:0;3:1;4:1;' ]
      }
      When run efu_run verify
      The status should be success
    End

    It '全件不一致なら終了状態1を返す'
      sxtest_run SX_CFG_SKIP_CHK -- 'sx_cfg_set "$@"' "SKIP_CHK=$1"
      __sx_num_is_nat0_safe() { return 0; }
      __sx_num_is_int_fit_dec() { return 1; }
      cb() { return 77; }
      When run efu_run sx_arg_find res cb 2 ::: a b
      The status should equal 1
    End
  End
End
