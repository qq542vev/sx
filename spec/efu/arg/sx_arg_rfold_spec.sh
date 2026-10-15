# shellcheck shell=sh disable=SC2329
# コールバックと検証用の差し替え関数は間接的に呼び出される。
Describe 'sx_arg_rfold -efu 環境検証'
  Include ./sx.sh

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
      sx_cfg_set "SKIP_CHK=$1"
      __sx_num_is_int_fit_dec() { return 1; }
      __sx_num_sub1_arith() { return 64; }
      inner_cb() { __sx_var_set "${1}=${2}[${4}:${3}]"; }
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
      sx_cfg_set "SKIP_CHK=$1"
      __sx_num_is_int_fit_dec() { return 1; }
      cb() { __sx_var_set "${1}=discard"; return 77; }
      When run efu_run sx_arg_rfold res cb init a b
      The status should equal 77
    End

    It '空リストでは数値経路を判定せず初期値を返す'
      sx_cfg_set "SKIP_CHK=$1"
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
