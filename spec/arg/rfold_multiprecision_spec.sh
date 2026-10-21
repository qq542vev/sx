# shellcheck shell=sh disable=SC2329
# コールバックと検証用の差し替え関数は間接的に呼び出される。

eval "$(shellspec - -c) exit 1"

Describe 'sx_arg_rfold 多倍長対応'
  Include ./spec/support/library.sh spec/arg/rfold_multiprecision_spec.sh SX_NUM_I8_MAX SX_NUM_I8_MIN SX_NUM_I8_QM SX_NUM_I8_WLEN SX_NUM_I8_ZR __sx_arg_rfold __sx_cfg_set __sx_num_is_int_fit_dec __sx_num_is_nat0_safe __sx_num_sub1_arith __sx_num_sub1_nat0 __sx_var_set sx_arg_rfold sx_cfg_set

  select_rfold_path() {
    case "$1" in
      arith) __sx_num_sub1_nat0() { return 64; };;
      nat0)
        __sx_num_is_int_fit_dec() { return 1; }
        __sx_num_sub1_arith() { return 64; }
        ;;
    esac
  }

  It '引数個数に安全範囲の上限を適用しない'
    __sx_num_is_nat0_safe() { return 1; }
    cb() { __sx_var_set "${1}=${2}${3}"; }
    When call sx_arg_rfold res cb init a b c
    The status should be success
    The variable res should equal initcba
  End

  Context '算術経路と多倍長経路'
    Parameters:matrix
      0 1
      arith nat0
    End

    It '右端から元の添字と特殊文字を含む値を渡す'
      sx_cfg_set "SKIP_CHK=$1"
      select_rfold_path "$2"
      cb() { __sx_var_set "${1}=${2}|${4}:${3}"; }
      When call sx_arg_rfold res cb init 'a b' '' "c'd"
      The status should be success
      The variable res should equal "init|3:c'd|2:|1:a b"
    End

    It '戻り値の未設定時はアキュムレータを保持し添字だけを進める'
      sx_cfg_set "SKIP_CHK=$1"
      select_rfold_path "$2"
      cb() {
        case "$3" in skip) return 0;; esac
        __sx_var_set "${1}=${2}|${4}:${3}"
      }
      When call sx_arg_rfold res cb init a skip c
      The status should be success
      The variable res should equal 'init|3:c|1:a'
    End

    It '空文字列の戻り値も新しいアキュムレータとして採用する'
      sx_cfg_set "SKIP_CHK=$1"
      select_rfold_path "$2"
      cb() {
        case "$3" in empty) __sx_var_set "${1}=";; *) __sx_var_set "${1}=${2}|${4}:${3}";; esac
      }
      When call sx_arg_rfold res cb init a empty c
      The status should be success
      The variable res should equal '|1:a'
    End

    It '失敗時の出力を破棄し直前のアキュムレータと終了状態を返す'
      sx_cfg_set "SKIP_CHK=$1"
      select_rfold_path "$2"
      calls=''
      cb() {
        calls="${calls}${4}:${3};"
        __sx_var_set "${1}=${2}|${4}:${3}"
        case "$4" in 2) return 77;; esac
        return 0
      }
      When call sx_arg_rfold res cb init a b c
      The status should equal 77
      The variable res should equal 'init|3:c'
      The variable calls should equal '3:c;2:b;'
    End

    It '結果変数へ再入しても外側のアキュムレータと添字を保持する'
      sx_cfg_set "SKIP_CHK=$1"
      select_rfold_path "$2"
      inner_cb() { __sx_var_set "${1}=${2}[${4}:${3}]"; }
      outer_cb() { sx_arg_rfold "$1" inner_cb "${2}|${4}" "${3}x" "${3}y"; }
      When call sx_arg_rfold res outer_cb init a b
      The status should be success
      The variable res should equal 'init|2[2:by][1:bx]|1[2:ay][1:ax]'
    End
  End

  It '再入呼び出しが別の数値経路を選んでも外側の経路を保持する'
    # 外側の最大位置10は多倍長、内側の最大位置7は算術を選ぶ。
    __sx_num_is_int_fit_dec() {
      case "${#}:${2-}" in 2:10) return 1;; esac
      return 0
    }
    inner_cb() { __sx_var_set "${1}=${2}[${4}:${3}]"; }
    outer_cb() { sx_arg_rfold "$1" inner_cb "${2}|${4}" "$3"; }
    When call sx_arg_rfold res outer_cb init a b c d
    The status should be success
    The variable res should equal 'init|4[1:d]|3[1:c]|2[1:b]|1[1:a]'
  End

  Context '空リストと直前の失敗状態'
    Parameters
      sx_arg_rfold 0
      sx_arg_rfold 1
      __sx_arg_rfold 0
    End

    It '数値経路を判定せず初期値と終了状態0を返す'
      sx_cfg_set "SKIP_CHK=$2"
      fit_called=0 called=0 res=old
      __sx_num_is_int_fit_dec() { fit_called=1; return 1; }
      cb() { called=1; }
      fail() { return 77; }
      after_failure() { fail || "$@"; }
      When call after_failure "$1" res cb 'init value'
      The status should be success
      The variable res should equal 'init value'
      The variable fit_called should equal 0
      The variable called should equal 0
    End
  End

  Context '8bit範囲の境界'
    Parameters
      121
      122
      127
      128
    End

    It '管理用の位置番号が算術域を超えても元の添字で全要素を処理する'
      count="$1" idx=0 expected=''
      set --
      while [ "$idx" -lt "$count" ]; do
        idx=$((idx + 1))
        set -- "$@" "value$idx"
        expected="|${idx}:value${idx}${expected}"
      done
      expected="init${expected}"
      # 公開設定の対象外である8bit幅を内部実装の境界検証に使う。
      __sx_cfg_set NUM_RANGE=8
      case "$count" in
        121) __sx_num_sub1_nat0() { return 64; };;
        *) __sx_num_sub1_arith() { return 64; };;
      esac
      first_idx=0 last_idx=0
      cb() {
        case "$first_idx" in 0) first_idx="$4";; esac
        last_idx="$4"
        __sx_var_set "${1}=${2}|${4}:${3}"
      }
      When call __sx_arg_rfold res cb init "$@"
      The status should be success
      The variable res should equal "$expected"
      The variable first_idx should equal "$count"
      The variable last_idx should equal 1
    End
  End
End
