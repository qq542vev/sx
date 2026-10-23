# shellcheck disable=SC2016 # CMD内の変数は準備用シェルで展開する。
# shellcheck shell=sh disable=SC2329
# コールバックと検証用の差し替え関数は間接的に呼び出される。

eval "$(shellspec - -c) exit 1"

Describe 'sx_arg_enough 多倍長対応'
  # Exampleごとに対象だけを読み込み、再入とスタブは検証側に残す。
  load_subject() {
    case "$1" in
      sx_arg_enough)
        Include ./spec/support/library.sh sx_arg_enough
        ;;
      __sx_arg_enough)
        Include ./spec/support/library.sh __sx_arg_enough
        ;;
      *) return 64;;
    esac
  }

  Include ./spec/support/run.sh

  select_enough_path() {
    case "$1" in
      arith)
        __sx_num_add1_nat0() { return 64; }
        __sx_num_sub1_nat0() { return 64; }
        ;;
      nat0)
        __sx_num_is_int_fit_dec() { return 1; }
        __sx_num_add1_arith() { return 64; }
        __sx_num_sub1_arith() { return 64; }
        ;;
    esac
  }

  It '引数個数と必要件数に安全範囲の上限を適用しない'
    load_subject sx_arg_enough
    __sx_num_is_nat0_safe() { return 1; }
    cb() { return 0; }
    When call sx_arg_enough cb 2 ::: a b c
    The status should be success
  End

  Context '算術経路と多倍長経路'
    Parameters:matrix
      0 1
      arith nat0
    End

    It '必要数に達した要素で成功し残りのコールバックを呼ばない'
      load_subject sx_arg_enough
      sxtest_run SX_CFG_SKIP_CHK -- 'sx_cfg_set "$@"' "SKIP_CHK=$1"
      select_enough_path "$2"
      calls=''
      cb() {
        calls="${calls}${2}:${1};"
        case "$1" in skip) return 77;; esac
        return 0
      }
      When call sx_arg_enough cb 2 ::: 'a b' skip "c'd" ''
      The status should be success
      The variable calls should equal "1:a b;2:skip;3:c'd;"
    End

    It '残りが不足した時点で失敗し次のコールバックを呼ばない'
      load_subject sx_arg_enough
      sxtest_run SX_CFG_SKIP_CHK -- 'sx_cfg_set "$@"' "SKIP_CHK=$1"
      select_enough_path "$2"
      calls=''
      cb() {
        calls="${calls}${2}:${1};"
        case "$1" in skip) return 77;; esac
        return 0
      }
      When call sx_arg_enough cb 3 ::: a skip c
      The status should equal 1
      The variable calls should equal '1:a;2:skip;'
    End

    It '初めから必要数に届かない場合はコールバックを呼ばない'
      load_subject sx_arg_enough
      sxtest_run SX_CFG_SKIP_CHK -- 'sx_cfg_set "$@"' "SKIP_CHK=$1"
      select_enough_path "$2"
      called=0
      cb() { called=1; return 0; }
      When call sx_arg_enough cb 4 ::: a b c
      The status should equal 1
      The variable called should equal 0
    End

    It '簡易形式では空文字列を含む全要素を必要数として扱う'
      load_subject sx_arg_enough
      sxtest_run SX_CFG_SKIP_CHK -- 'sx_cfg_set "$@"' "SKIP_CHK=$1"
      select_enough_path "$2"
      calls=''
      cb() { calls="${calls}${2}:${1};"; }
      When call sx_arg_enough cb 'a b' '' "c'd"
      The status should be success
      The variable calls should equal "1:a b;2:;3:c'd;"
    End

    It '再入しても外側の添字と残件数と必要件数を保持する'
      load_subject sx_arg_enough
      sxtest_run SX_CFG_SKIP_CHK -- 'sx_cfg_set "$@"' "SKIP_CHK=$1"
      select_enough_path "$2"
      calls=''
      inner_cb() { return 0; }
      cb() {
        sx_arg_enough inner_cb 1 ::: x y
        calls="${calls}${2}:${1};"
        case "$1" in b) return 77;; esac
        return 0
      }
      When call sx_arg_enough cb 2 ::: a b c d
      The status should be success
      The variable calls should equal '1:a;2:b;3:c;'
    End
  End

  It '再入呼び出しが別の数値経路を選んでも外側の経路を保持する'
    load_subject sx_arg_enough
    __sx_num_is_int_fit_dec() {
      case "${#}:${2-}:${3-}" in 3:4:2) return 1;; esac
      return 0
    }
    calls=''
    inner_cb() { return 0; }
    cb() {
      sx_arg_enough inner_cb 1 ::: x
      calls="${calls}${2}:${1};"
      case "$1" in b) return 77;; esac
      return 0
    }
    When call sx_arg_enough cb 2 ::: a b c d
    The status should be success
    The variable calls should equal '1:a;2:b;3:c;'
  End

  Context '必要数0'
    Parameters
      0
      1
    End

    It '数値経路を判定せず成功しコールバックを呼ばない'
      load_subject sx_arg_enough
      sxtest_run SX_CFG_SKIP_CHK -- 'sx_cfg_set "$@"' "SKIP_CHK=$1"
      fit_called=0 called=0
      __sx_num_is_int_fit_dec() { fit_called=1; return 1; }
      cb() { called=1; }
      When call sx_arg_enough cb 0 ::: a b
      The status should be success
      The variable fit_called should equal 0
      The variable called should equal 0
    End
  End

  Context '空入力で正の必要数'
    Parameters
      0
      1
    End

    It '数値経路を判定せず失敗しコールバックを呼ばない'
      load_subject sx_arg_enough
      sxtest_run SX_CFG_SKIP_CHK -- 'sx_cfg_set "$@"' "SKIP_CHK=$1"
      fit_called=0 called=0
      __sx_num_is_int_fit_dec() { fit_called=1; return 1; }
      cb() { called=1; }
      When call sx_arg_enough cb 1 :::
      The status should equal 1
      The variable fit_called should equal 0
      The variable called should equal 0
    End
  End

  Context 'ネイティブ算術域を超える必要件数'
    Parameters:matrix
      0 1
      9223372036854775808 18446744073709551616 10000000000000000000000000000000000000000
    End

    It '必要件数を拒否せず不足として扱いコールバックを呼ばない'
      load_subject sx_arg_enough
      sxtest_run SX_CFG_SKIP_CHK -- 'sx_cfg_set "$@"' "SKIP_CHK=$1"
      called=0
      cb() { called=1; return 0; }
      When call sx_arg_enough cb "$2" ::: a b c
      The status should equal 1
      The variable called should equal 0
    End
  End

  Context '必要件数の形式検証'
    Parameters
      # ShellSpecのデータ行であり、コマンドとして実行されない。
      # shellcheck disable=SC2286
      ''
      # shellcheck disable=SC2215
      -1
      +1
      00
      07
      08
      0177
      0x
      0x0
      0x00
      0X10
      2.0
      1e2
      '1+1'
    End

    It '不正な形式を拒否しコールバックを呼ばない'
      load_subject sx_arg_enough
      called=0
      cb() { called=1; return 0; }
      When call sx_arg_enough cb "$1" ::: a b
      The status should equal 64
      The variable called should equal 0
    End
  End

  Context '8bit範囲の境界'
    Parameters
      127 127 0 127 arith
      128 128 0 128 nat0
      127 128 1 0 nat0
      128 127 0 127 nat0
      128 default 0 128 nat0
    End

    It '算術域の前後で正しい添字と必要数で短絡終了する'
      load_subject __sx_arg_enough
      count="$1" need="$2" expected_status="$3" expected_calls="$4" path="$5"
      idx=0
      set --
      while [ "$idx" -lt "$count" ]; do
        idx=$((idx + 1))
        set -- "$@" x
      done
      # 公開設定の対象外である8bit幅を内部実装の境界検証に使う。
      sxtest_run SX_CFG_NUM_RANGE SX_SYS_NUM_QM SX_SYS_NUM_ZR -- '__sx_cfg_set "$@"' NUM_RANGE=8
      case "$path" in
        arith)
          __sx_num_add1_nat0() { return 64; }
          __sx_num_sub1_nat0() { return 64; }
          ;;
        nat0)
          __sx_num_add1_arith() { return 64; }
          __sx_num_sub1_arith() { return 64; }
          ;;
      esac
      calls=0 last_idx=0
      cb() { calls=$((calls + 1)); last_idx="$2"; return 0; }
      case "$need" in
        default) set -- cb "$@";;
        *) set -- cb "$need" ::: "$@";;
      esac
      When call __sx_arg_enough "$@"
      The status should equal "$expected_status"
      The variable calls should equal "$expected_calls"
      The variable last_idx should equal "$expected_calls"
    End
  End
End
