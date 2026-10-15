# shellcheck shell=sh disable=SC2329
# コールバックと検証用の差し替え関数は間接的に呼び出される。
Describe 'sx_arg_enough -efu 環境検証'
  Include ./sx.sh

  It '正常動作'

    When run efu_run sx_arg_enough efu_cb_true 2 ::: a b c
    The status should be success
  End

  Context '多倍長経路'
    Parameters
      0
      1
    End

    It '再入後も必要数で短絡成功する'
      sx_cfg_set "SKIP_CHK=$1"
      __sx_num_is_int_fit_dec() { return 1; }
      __sx_num_add1_arith() { return 64; }
      __sx_num_sub1_arith() { return 64; }
      calls=''
      inner_cb() { return 0; }
      cb() {
        sx_arg_enough inner_cb 1 ::: x
        calls="${calls}${2}:${1};"
        case "$1" in b) return 77;; esac
        return 0
      }
      verify() {
        sx_arg_enough cb 2 ::: a b c d
        [ "$calls" = '1:a;2:b;3:c;' ]
      }
      When run efu_run verify
      The status should be success
    End

    It '残件数が不足した場合は終了状態1を返す'
      sx_cfg_set "SKIP_CHK=$1"
      __sx_num_is_int_fit_dec() { return 1; }
      cb() { return 77; }
      When run efu_run sx_arg_enough cb 2 ::: a b c
      The status should equal 1
    End

    It '必要数0では成功してコールバックを呼ばない'
      sx_cfg_set "SKIP_CHK=$1"
      cb() { return 77; }
      When run efu_run sx_arg_enough cb 0 ::: a b
      The status should be success
    End
  End
End
