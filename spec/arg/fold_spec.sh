# shellcheck disable=SC2016 # CMD内の変数は準備用シェルで展開する。
# shellcheck shell=sh disable=SC2329
# コールバックと検証用の差し替え関数はShellSpec経由で間接的に呼び出される。

eval "$(shellspec - -c) exit 1"

Describe 'sx_arg_fold'
  # Exampleごとに公開API・内部実装の対象だけを読み込む。
  load_subject() {
    case "$1" in
      sx_arg_fold)
        Include ./spec/support/library.sh sx_arg_fold
        ;;
      __sx_arg_fold)
        Include ./spec/support/library.sh __sx_arg_fold
        ;;
      *) return 64;;
    esac
  }

  # 補助処理だけを別シェルへ移し、対象関数への再入は同じシェル内で行う。
  Include ./spec/support/setup.sh

  select_fold_path() {
    case "$1" in
      arith) __sx_num_add1_nat0() { return 64; };;
      nat0)
        __sx_num_is_int_fit_dec() { return 1; }
        __sx_num_add1_arith() { return 64; }
        ;;
    esac
  }

  It '引数個数に安全範囲の上限を適用しない'
    load_subject sx_arg_fold
    __sx_num_is_nat0_safe() { return 1; }
    cb() { sxtest_setup "${1}" -- 'sx_var_set "$@"' "${1}=${2}${3}"; }
    When call sx_arg_fold res cb init a b c
    The status should be success
    The variable res should equal initabc
  End

  Context '算術経路と多倍長経路'
    Parameters
      0 arith
      0 nat0
      1 arith
      1 nat0
    End

    It '検証の有無によらずアキュムレータと値と添字を渡す'
      load_subject sx_arg_fold
      sxtest_setup SX_CFG_SKIP_CHK -- 'sx_cfg_set "$@"' "SKIP_CHK=$1"
      select_fold_path "$2"
      cb() { sxtest_setup "${1}" -- 'sx_var_set "$@"' "${1}=${2}|${4}:${3}"; }
      When call sx_arg_fold res cb init 'a b' '' "c'd"
      The status should be success
      The variable res should equal "init|1:a b|2:|3:c'd"
    End

    It 'スキップ時はアキュムレータを保持し添字だけを進める'
      load_subject sx_arg_fold
      sxtest_setup SX_CFG_SKIP_CHK -- 'sx_cfg_set "$@"' "SKIP_CHK=$1"
      select_fold_path "$2"
      cb() {
        case "$3" in skip) return 0;; esac
        sxtest_setup "${1}" -- 'sx_var_set "$@"' "${1}=${2}|${4}:${3}"
      }
      When call sx_arg_fold res cb init a skip c
      The status should be success
      The variable res should equal 'init|1:a|3:c'
    End

    It '空文字列の結果も新しいアキュムレータとして採用する'
      load_subject sx_arg_fold
      sxtest_setup SX_CFG_SKIP_CHK -- 'sx_cfg_set "$@"' "SKIP_CHK=$1"
      select_fold_path "$2"
      cb() {
        case "$3" in empty) sxtest_setup "${1}" -- 'sx_var_set "$@"' "${1}=";; *) sxtest_setup "${1}" -- 'sx_var_set "$@"' "${1}=${2}${3}";; esac
      }
      When call sx_arg_fold res cb init a empty c
      The status should be success
      The variable res should equal c
    End

    It '失敗時の出力を破棄し直前のアキュムレータと終了状態を返す'
      load_subject sx_arg_fold
      sxtest_setup SX_CFG_SKIP_CHK -- 'sx_cfg_set "$@"' "SKIP_CHK=$1"
      select_fold_path "$2"
      calls=
      cb() {
        calls="${calls}${4}:${3};"
        sxtest_setup "${1}" -- 'sx_var_set "$@"' "${1}=${2}|${4}:${3}"
        case "$4" in 2) return 77;; esac
        return 0
      }
      When call sx_arg_fold res cb init a b c
      The status should equal 77
      The variable res should equal 'init|1:a'
      The variable calls should equal '1:a;2:b;'
    End

    It '結果変数へ再入しても外側のアキュムレータと添字を保持する'
      load_subject sx_arg_fold
      sxtest_setup SX_CFG_SKIP_CHK -- 'sx_cfg_set "$@"' "SKIP_CHK=$1"
      select_fold_path "$2"
      inner_cb() { sxtest_setup "${1}" -- 'sx_var_set "$@"' "${1}=${2}[${4}:${3}]"; }
      outer_cb() { sx_arg_fold "$1" inner_cb "${2}|${4}" "${3}x" "${3}y"; }
      When call sx_arg_fold res outer_cb init a b
      The status should be success
      The variable res should equal 'init|1[1:ax][2:ay]|2[1:bx][2:by]'
    End
  End

  It '再入呼び出しが別の数値経路を選んでも外側の経路を保持する'
    load_subject sx_arg_fold
    # 外側は5引数で多倍長、内側は4引数で算術を選ぶ。
    __sx_num_is_int_fit_dec() {
      case "${#}:${2-}" in 2:5) return 1;; esac
      return 0
    }
    inner_cb() { sxtest_setup "${1}" -- 'sx_var_set "$@"' "${1}=${2}[${4}:${3}]"; }
    outer_cb() { sx_arg_fold "$1" inner_cb "${2}|${4}" "${3}x"; }
    When call sx_arg_fold res outer_cb init a b
    The status should be success
    The variable res should equal 'init|1[1:ax]|2[1:bx]'
  End

  It 'コールバックでネイティブ算術域を超える値を加算できる'
    load_subject sx_arg_fold
    cb() { sxtest_setup "$1" -- 'sx_num_add_int "$@"' "$1" "$2" "$3"; }
    When call sx_arg_fold res cb 9223372036854775807 2 -1
    The status should be success
    The variable res should equal 9223372036854775808
  End

  Context '8bit範囲の境界'
    Parameters
      124
      125
      127
      128
    End

    It '算術域の前後で全要素を畳み込み最後の添字を渡す'
      load_subject __sx_arg_fold
      expected_idx="$1"
      args=
      sxtest_setup args -- 'sx_str_rep "$@"' args "'x' " "$expected_idx"
      expected=
      sxtest_setup expected -- 'sx_str_rep "$@"' expected x "$expected_idx"
      eval "set -- $args"
      # 公開設定の対象外である8bit幅を内部実装の境界検証に使う。
      sxtest_setup SX_CFG_NUM_RANGE SX_SYS_NUM_QM SX_SYS_NUM_ZR -- '__sx_cfg_set "$@"' NUM_RANGE=8
      case "$expected_idx" in
        124) __sx_num_add1_nat0() { return 64; };;
        *) __sx_num_add1_arith() { return 64; };;
      esac
      last_idx=0
      cb() { sxtest_setup "${1}" -- 'sx_var_set "$@"' "${1}=${2}${3}"; last_idx="$4"; }
      When call __sx_arg_fold res cb '' "$@"
      The status should be success
      The variable res should equal "$expected"
      The variable last_idx should equal "$expected_idx"
    End
  End

  Context '空リストと直前の失敗状態'
    Parameters
      sx_arg_fold 0
      sx_arg_fold 1
      __sx_arg_fold 0
    End

    It '数値経路を判定せず初期値と終了状態0を返す'
      load_subject "$1"
      sxtest_setup SX_CFG_SKIP_CHK -- 'sx_cfg_set "$@"' "SKIP_CHK=$2"
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

  Describe '基本畳み込み: 数値の合計'
    It '初期値 0 で合計を計算する'
      load_subject sx_arg_fold
      sum() { sxtest_setup "$1" -- 'sx_var_set "$@"' "$1=$(($2 + $3))"; }
      When call sx_arg_fold res sum 0 1 2 3 4 5
      The status should be success
      The variable res should equal 15
    End

    It '初期値 10 で合計を計算する'
      load_subject sx_arg_fold
      sum() { sxtest_setup "$1" -- 'sx_var_set "$@"' "$1=$(($2 + $3))"; }
      When call sx_arg_fold res sum 10 1 2 3
      The status should be success
      The variable res should equal 16
    End
  End

  Describe '基本畳み込み: 文字列連結'
    It '文字列を連結する'
      load_subject sx_arg_fold
      concat() { sxtest_setup "$1" -- 'sx_var_set "$@"' "$1=$2$3"; }
      When call sx_arg_fold res concat '' a b c
      The status should be success
      The variable res should equal "abc"
    End

    It '区切り文字付き連結'
      load_subject sx_arg_fold
      join_with_comma() { sxtest_setup "$1" -- 'sx_var_set "$@"' "$1=$2,$3"; }
      When call sx_arg_fold res join_with_comma '' a b c
      The status should be success
      The variable res should equal ",a,b,c"
    End
  End

  Describe 'スキップ: ret を unset でアキュムレータ維持'
    It '条件に合わない要素をスキップする'
      load_subject sx_arg_fold
      sum_even() {
        case $(($3 % 2)) in 0) sxtest_setup "$1" -- 'sx_var_set "$@"' "$1=$(($2 + $3))"; esac
      }
      When call sx_arg_fold res sum_even 0 1 2 3 4
      The status should be success
      The variable res should equal 6
    End

    It '全要素スキップすると初期値が返る'
      load_subject sx_arg_fold
      skipall() { :; }
      When call sx_arg_fold res skipall 42 a b c
      The status should be success
      The variable res should equal 42
    End
  End

  Describe 'コールバックエラーで即時終了'
    It 'cb が非0を返すとその時点の acc とエラーステータスを返す'
      load_subject sx_arg_fold
      err_on_b() { case $3 in b) return 2;; esac; sxtest_setup "$1" -- 'sx_var_set "$@"' "$1=$(($2 + 1))"; }
      When call sx_arg_fold res err_on_b 0 a b c
      The status should equal 2
      The variable res should equal 1
    End

    It 'エラー発生以降の要素は処理されない'
      load_subject sx_arg_fold
      cnt=0
      err_then_stop() {
        : $((cnt += 1))
        case $3 in b) return 2;; esac
        sxtest_setup "$1" -- 'sx_var_set "$@"' "$1=$(($2 + 1))"
      }
      When call sx_arg_fold res err_then_stop 0 a b c d e
      The status should equal 2
      The variable res should equal 1
      The variable cnt should equal 2
    End

    It '最初の要素でエラーになると初期値が返る'
      load_subject sx_arg_fold
      always_err() { return 3; }
      When call sx_arg_fold res always_err 99 a b c
      The status should equal 3
      The variable res should equal 99
    End
  End

  Describe '空リスト'
    It '要素がない場合、初期値がそのまま返る'
      load_subject sx_arg_fold
      cb() { sxtest_setup "$1" -- 'sx_var_set "$@"' "$1=changed"; }
      When call sx_arg_fold res cb init
      The status should be success
      The variable res should equal "init"
    End
  End

  Describe '単一要素'
    It '1要素だけ処理する'
      load_subject sx_arg_fold
      sum() { sxtest_setup "$1" -- 'sx_var_set "$@"' "$1=$(($2 + $3))"; }
      When call sx_arg_fold res sum 5 7
      The status should be success
      The variable res should equal 12
    End
  End

  Describe 'エラーケース'
    It '結果変数が読み取り専用の場合に EX_NOPERM を返す'
      load_subject sx_arg_fold
      cb() { sxtest_setup "$1" -- 'sx_var_set "$@"' "$1=$(($2 + $3))"; }
      readonly ro_fold=0
      When call sx_arg_fold ro_fold cb 0 a
      The status should equal 77
    End
  End

  Describe '高速モード (SX_CFG_SKIP_CHK=1)'
    It 'チェックをスキップして fold する'
      load_subject sx_arg_fold
      sum() { sxtest_setup "$1" -- 'sx_var_set "$@"' "$1=$(($2 + $3))"; }
      SX_CFG_SKIP_CHK=1
      When call sx_arg_fold res sum 0 1 2 3
      The status should be success
      The variable res should equal 6
    End
  End

  Describe '内部関数 (__sx_arg_fold)'
    It '__sx_arg_fold が正しく動作する'
      load_subject __sx_arg_fold
      sum() { sxtest_setup "$1" -- 'sx_var_set "$@"' "$1=$(($2 + $3))"; }
      When call __sx_arg_fold res sum 0 1 2 3
      The status should be success
      The variable res should equal 6
    End
  End

  Describe '再帰呼び出し'
    It 'fold 内で fold を呼び出しても状態が壊れない'
      load_subject sx_arg_fold
      inner_sum() { sxtest_setup "$1" -- 'sx_var_set "$@"' "$1=$(($2 + $3))"; }
      outer_fold() {
        __sx_arg_fold __sx_arg_fold_tmp inner_sum "$2" "$3" 0
        eval "$1=\${__sx_arg_fold_tmp}"
        unset __sx_arg_fold_tmp
      }
      When call sx_arg_fold res outer_fold 0 1 2 3
      The status should be success
      The variable res should equal 6
    End
  End
End
