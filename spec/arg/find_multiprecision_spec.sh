# shellcheck shell=sh disable=SC2329
# コールバックと検証用の差し替え関数はShellSpec経由で間接的に呼び出される。

eval "$(shellspec - -c) exit 1"

Describe 'sx_arg_find 多倍長対応'
  Include ./sx.sh

  select_find_path() {
    case "$1" in
      arith) __sx_num_add1_nat0() { return 64; };;
      nat0)
        # フラグ検証からの範囲判定を分離し、検索の経路だけを切り替える。
        __sx_num_is_nat0_safe() { return 0; }
        __sx_num_is_int_fit_dec() { return 1; }
        __sx_num_add1_arith() { return 64; }
        ;;
    esac
  }

  is_b() { case "$1" in 'b a') return 0;; esac; return 77; }

  Context '算術経路と多倍長経路'
    Parameters:matrix
      0 1
      arith nat0
      0 1 2 4 5 6
    End

    It '検証の有無によらずリテラル・glob・コールバックで添字と値を収集する'
      sx_cfg_set "SKIP_CHK=$1"
      select_find_path "$2"
      flags="$3"
      case "$flags" in
        0 | 4) target='b a';;
        1 | 5) target='b*';;
        *) target=is_b;;
      esac
      case "$flags" in
        0 | 1 | 2) expected='2 4';;
        *) expected="'b a' 'b a'";;
      esac
      When call sx_arg_find res "$target" "$flags" ::: other 'b a' '' 'b a'
      The status should be success
      The variable res should equal "$expected"
    End
  End

  Context 'コールバックの状態管理'
    Parameters:matrix
      0 1
      arith nat0
    End

    It '現在の添字と処理前の一致数を渡し非0は不一致として扱う'
      sx_cfg_set "SKIP_CHK=$1"
      select_find_path "$2"
      calls=
      cb() { calls="${calls}${2}:${3};"; is_b "$1"; }
      When call sx_arg_find res cb 2 ::: a 'b a' c 'b a'
      The status should be success
      The variable res should equal '2 4'
      The variable calls should equal '1:0;2:0;3:1;4:1;'
    End

    It 'バインド枯渇後はコールバックを呼ばない'
      sx_cfg_set "SKIP_CHK=$1"
      select_find_path "$2"
      calls=
      cb() { calls="${calls}${2}:${3};"; }
      When call sx_arg_find 'idx_a:idx_b:' cb 2 ::: a b c
      The status should be success
      The variable idx_a should equal 1
      The variable idx_b should equal 2
      The variable calls should equal '1:0;2:1;'
    End

    It '再入しても外側の添字と一致数とバインドを保持する'
      sx_cfg_set "SKIP_CHK=$1"
      select_find_path "$2"
      calls=
      inner_cb() { return 0; }
      cb() {
        sx_arg_find nested_result inner_cb 2 ::: x y
        calls="${calls}${2}:${3};"
        is_b "$1"
      }
      When call sx_arg_find res cb 2 ::: a 'b a' c 'b a'
      The status should be success
      The variable res should equal '2 4'
      The variable nested_result should equal '1 2'
      The variable calls should equal '1:0;2:0;3:1;4:1;'
    End
  End

  It '再入呼び出しが別の数値経路を選んでも外側の経路を保持する'
    __sx_num_is_int_fit_dec() {
      case "${#}:${2-}" in 2:7) return 1;; esac
      return 0
    }
    calls=
    inner_cb() { return 0; }
    cb() {
      sx_arg_find nested_result inner_cb 2 ::: x y
      calls="${calls}${2}:${3};"
      is_b "$1"
    }
    When call sx_arg_find res cb 2 ::: a 'b a' c 'b a'
    The status should be success
    The variable res should equal '2 4'
    The variable calls should equal '1:0;2:0;3:1;4:1;'
  End

  Context '一致項目なし'
    Parameters
      0 missing
      1 'z*'
      2 never
      4 missing
      5 'z*'
      6 never
    End

    It '多倍長経路でも結果を初期化して終了状態1を返す'
      select_find_path nat0
      res=old
      never() { return 77; }
      When call sx_arg_find res "$2" "$1" ::: a b
      The status should equal 1
      The variable res should equal ''
    End
  End

  Context '空の入力と空のバインド'
    Parameters
      0 ''
      1 ''
      0 res
      1 res
    End

    It '数値経路を判定せず終了状態1を返す'
      sx_cfg_set "SKIP_CHK=$1"
      fit_called=0 called=0 res=old
      __sx_num_is_nat0_safe() { return 0; }
      __sx_num_is_int_fit_dec() { fit_called=1; return 1; }
      cb() { called=1; }
      case "$2" in '') set -- ::: a b;; *) set -- res cb 2 :::;; esac
      When call sx_arg_find "$@"
      The status should equal 1
      The variable fit_called should equal 0
      The variable called should equal 0
    End
  End

  Context '引数個数の上限撤廃'
    Parameters
      0 b
      1 'b*'
      2 cb
    End

    It '引数個数に安全範囲の上限を適用しない'
      __sx_num_is_nat0_safe() { case "$1" in 6) return 1;; esac; return 0; }
      cb() { case "$1" in b) return 0;; esac; return 77; }
      When call sx_arg_find res "$2" "$1" ::: a b
      The status should be success
      The variable res should equal 2
    End
  End

  It 'フラグには引き続き数値範囲検証を適用する'
    sx_cfg_set NUM_RANGE=32
    res=old
    When call sx_arg_find res b 2147483648 ::: a b
    The status should equal 64
    The variable res should equal old
  End

  It '検索対象を省略して空文字列を探せる'
    select_find_path nat0
    When call sx_arg_find res '' x ''
    The status should be success
    The variable res should equal '1 3'
  End

  It 'TEXTモードで空文字列と引用符を復元できる'
    select_find_path nat0
    restore() {
      sx_arg_find res '*' 5 ::: '' 'a b' "c'd" ''
      # shellcheck disable=SC2154
      eval "set -- $res"
      [ "$#" = 4 ] && [ "$1" = '' ] && [ "$2" = 'a b' ] && [ "$3" = "c'd" ] && [ "$4" = '' ]
    }
    When call restore
    The status should be success
  End

  Context '8bit範囲の境界'
    Parameters:matrix
      124 127 128
      0 1 2
    End

    It '算術域の前後で最後の添字と一致数まで更新する'
      expected_idx="$1" flags="$2"
      expected_count=$((expected_idx - 1))
      args=
      sx_str_rep args "'x' " "$expected_idx"
      eval "set -- $args"
      expected='' idx=0
      while [ "$idx" -lt "$expected_idx" ]; do
        idx=$((idx + 1))
        expected="${expected}${expected:+ }${idx}"
      done
      # 公開設定の対象外である8bit幅を内部実装の境界検証に使う。
      __sx_cfg_set NUM_RANGE=8
      case "${expected_idx}:${flags}" in
        124:* | 127:0 | 127:1) __sx_num_add1_nat0() { return 64; };;
        *) __sx_num_add1_arith() { return 64; };;
      esac
      last_idx=0 last_count=0
      cb() { last_idx="$2"; last_count="$3"; }
      case "$flags" in 2) target=cb;; *) target=x;; esac
      When call __sx_arg_find res "$target" "$flags" ::: "$@"
      The status should be success
      The variable res should equal "$expected"
      case "$flags" in 2)
        The variable last_idx should equal "$expected_idx"
        The variable last_count should equal "$expected_count"
      esac
    End
  End
End
