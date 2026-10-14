# shellcheck shell=sh disable=SC2329
# コールバックと検証用の差し替え関数は間接的に呼び出される。
Describe 'sx_arg_count -efu 環境検証'
  Include ./sx.sh

  It '正常動作'

    When run efu_run sx_arg_count res "b" ::: "a" "b" "c"
    The status should be success
  End

  Context '多倍長経路'
    Parameters:matrix
      0 1
      0 1 2 4 5 6
    End

    It '検証の有無によらずすべての検索モードで件数を返す'
      sx_cfg_set "SKIP_CHK=$1"
      __sx_num_is_nat0_safe() { return 0; }
      __sx_num_is_int_fit_dec() { return 1; }
      __sx_num_add1_arith() { return 64; }
      flags="$2" res=''
      cb() { case "$1" in b) return 0;; esac; return 77; }
      case "$flags" in
        0 | 4) target=b;;
        1 | 5) target='b*';;
        *) target=cb;;
      esac
      verify() {
        sx_arg_count res "$target" "$flags" ::: a b '' b
        [ "$res" = 2 ]
      }
      When run efu_run verify
      The status should be success
    End
  End

  Context '多倍長経路で一致項目なし'
    Parameters
      0
      1
    End

    It '不一致と空入力でも成功して件数0を返す'
      sx_cfg_set "SKIP_CHK=$1"
      __sx_num_is_nat0_safe() { return 0; }
      __sx_num_is_int_fit_dec() { return 1; }
      cb() { return 77; }
      res=''
      verify() {
        sx_arg_count res cb 2 ::: a b
        [ "$res" = 0 ] || return 1
        sx_arg_count res cb 2 :::
        [ "$res" = 0 ]
      }
      When run efu_run verify
      The status should be success
    End
  End
End
