# shellcheck shell=sh disable=SC2329
# 検証用の差し替え関数は間接的に呼び出される。
Describe 'sx_arg_rquote -efu 環境検証'
  Include ./spec/support/library.sh spec/efu/arg/sx_arg_rquote_spec.sh __sx_num_is_int_fit_dec __sx_num_sub1_arith __sx_num_sub1_nat0 sx_arg_rquote sx_cfg_set

  It '正常動作'

    When run efu_run sx_arg_rquote reversed_args "$@"
    The status should be success
  End

  Context '多倍長経路'
    Parameters
      0
      1
    End

    It '空要素を保持して逆順に取得しバインド枯渇時に終了する'
      sx_cfg_set "SKIP_CHK=$1"
      __sx_num_is_int_fit_dec() { return 1; }
      __sx_num_sub1_arith() { return 64; }
      res=''
      verify() {
        sx_arg_rquote '2res:' 'a b' '' "c'd"
        eval "set -- $res"
        [ "$#" = 2 ] && [ "$1" = "c'd" ] && [ "$2" = '' ]
      }
      When run efu_run verify
      The status should be success
    End

    It '空入力では結果を初期化して成功する'
      sx_cfg_set "SKIP_CHK=$1"
      __sx_num_is_int_fit_dec() { return 64; }
      __sx_num_sub1_arith() { return 64; }
      __sx_num_sub1_nat0() { return 64; }
      res=old
      verify() {
        sx_arg_rquote res
        [ "$res" = '' ]
      }
      When run efu_run verify
      The status should be success
    End
  End
End
