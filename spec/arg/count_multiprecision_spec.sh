# shellcheck shell=sh disable=SC2329
# コールバックと検証用の差し替え関数はShellSpec経由で間接的に呼び出される。

eval "$(shellspec - -c) exit 1"

Describe 'sx_arg_count 多倍長対応'
  Include ./spec/support/library.sh spec/arg/count_multiprecision_spec.sh SX_CFG_NUM_RANGE SX_NUM_I8_MAX SX_NUM_I8_MIN SX_NUM_I8_QM SX_NUM_I8_WLEN SX_NUM_I8_ZR __sx_arg_count __sx_cfg_set __sx_num_add1_arith __sx_num_add1_nat0 __sx_num_is_int_fit_dec __sx_num_is_nat0_safe sx_arg_count sx_cfg_set sx_str_rep

  select_count_path() {
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

  Context '引数個数の上限撤廃'
    Parameters
      0 b
      1 'b*'
      2 cb
    End

    It '引数個数に安全範囲の上限を適用しない'
      __sx_num_is_nat0_safe() { case "$1" in 6) return 1;; esac; return 0; }
      cb() { case "$1" in b) return 0;; esac; return 77; }
      When call sx_arg_count res "$2" "$1" ::: a b
      The status should be success
      The variable res should equal 1
    End
  End

  Context '算術経路と多倍長経路'
    Parameters:matrix
      0 1
      arith nat0
      0 1 2 4 5 6
    End

    It '検証の有無によらずリテラル・glob・コールバックで件数を数える'
      sx_cfg_set "SKIP_CHK=$1"
      select_count_path "$2"
      flags="$3" calls=''
      cb() {
        calls="${calls}${2}:${3};"
        case "$1" in 'b a') return 0;; esac
        return 77
      }
      case "$flags" in
        0 | 4) target='b a';;
        1 | 5) target='b*';;
        *) target=cb;;
      esac
      When call sx_arg_count res "$target" "$flags" ::: other 'b a' '' 'b a'
      The status should be success
      The variable res should equal 2
      case "$flags" in 2 | 6)
        The variable calls should equal '1:0;2:0;3:1;4:1;'
      esac
    End
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

    It '多倍長経路でも終了状態0で件数0を返す'
      select_count_path nat0
      res=old
      never() { return 77; }
      When call sx_arg_count res "$2" "$1" ::: a b
      The status should be success
      The variable res should equal 0
    End
  End

  Context '空リスト'
    Parameters
      0
      1
    End

    It '数値経路を判定せず件数0を返す'
      sx_cfg_set "SKIP_CHK=$1"
      fit_called=0 called=0 res=old
      __sx_num_is_nat0_safe() { return 0; }
      __sx_num_is_int_fit_dec() { fit_called=1; return 1; }
      cb() { called=1; }
      When call sx_arg_count res cb 2 :::
      The status should be success
      The variable res should equal 0
      The variable fit_called should equal 0
      The variable called should equal 0
    End
  End

  Context 'TEXTモードの値の復元'
    Parameters
      5 '*'
      6 cb
    End

    It '空文字列と引用符とシェル構文を含む値を各1件として数える'
      select_count_path nat0
      cb() { return 0; }
      # シェル構文を評価せず値として渡し、内部evalで再評価されないことを確認する。
      # shellcheck disable=SC2016
      When call sx_arg_count res "$2" "$1" ::: '' 'a b' "c'd" '$(exit 99); *'
      The status should be success
      The variable res should equal 4
    End
  End

  It '簡易形式でも多倍長経路で空要素を数える'
    select_count_path nat0
    When call sx_arg_count res '' '' x ''
    The status should be success
    The variable res should equal 2
  End

  It 'フラグには引き続き数値範囲検証を適用する'
    sx_cfg_set NUM_RANGE=32
    res=old
    When call sx_arg_count res b 2147483648 ::: a b
    The status should equal 64
    The variable res should equal old
  End

  It '不正な数値範囲設定は引き続き拒否する'
    SX_CFG_NUM_RANGE=bogus
    res=old
    When call sx_arg_count res b ::: a b
    The status should equal 78
    The variable res should equal old
  End

  Context '8bit範囲の境界'
    Parameters:matrix
      124 127 128
      0 1 2 4 5 6
    End

    It '算術域の前後で添字と一致数を更新し全件を数える'
      expected_count="$1" flags="$2"
      expected_prior=$((expected_count - 1))
      args=
      sx_str_rep args "'x' " "$expected_count"
      eval "set -- $args"
      # 公開設定の対象外である8bit幅を内部実装の境界検証に使う。
      __sx_cfg_set NUM_RANGE=8
      case "${expected_count}:${flags}" in
        124:* | 127:0 | 127:1 | 127:4 | 127:5) __sx_num_add1_nat0() { return 64; };;
        *) __sx_num_add1_arith() { return 64; };;
      esac
      last_idx=0 last_count=0
      cb() { last_idx="$2"; last_count="$3"; }
      case "$flags" in 2 | 6) target=cb;; *) target=x;; esac
      When call __sx_arg_count res "$target" "$flags" ::: "$@"
      The status should be success
      The variable res should equal "$expected_count"
      case "$flags" in 2 | 6)
        The variable last_idx should equal "$expected_count"
        The variable last_count should equal "$expected_prior"
      esac
    End
  End
End
