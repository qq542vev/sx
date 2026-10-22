# shellcheck shell=sh disable=SC2329
# コールバックと検証用の差し替え関数は間接的に呼び出される。

eval "$(shellspec - -c) exit 1"

Describe 'sx_arg_rfind 多倍長対応'
  # Exampleごとに対象だけを読み込み、再入とスタブは検証側に残す。
  load_subject() {
    case "$1" in
      sx_arg_rfind)
        Include ./spec/support/library.sh sx_arg_rfind
        ;;
      __sx_arg_rfind)
        Include ./spec/support/library.sh __sx_arg_rfind
        ;;
      *) return 64;;
    esac
  }

  Include ./spec/support/prepare.sh

  select_rfind_path() {
    case "$1" in
      arith)
        __sx_num_sub1_nat0() { return 64; }
        __sx_num_add1_nat0() { return 64; }
        ;;
      nat0)
        # フラグ検証からの範囲判定を分離し、検索の経路だけを切り替える。
        __sx_num_is_nat0_safe() { return 0; }
        __sx_num_is_int_fit_dec() { return 1; }
        __sx_num_sub1_arith() { return 64; }
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

    It '検証の有無によらず各検索モードで逆順に添字と値を収集する'
      load_subject sx_arg_rfind
      sx_test_setup sx_cfg_set "SKIP_CHK=$1"
      select_rfind_path "$2"
      flags="$3"
      case "$flags" in
        0 | 4) target='b a';;
        1 | 5) target='b*';;
        *) target=is_b;;
      esac
      case "$flags" in
        0 | 1 | 2) expected='4 2';;
        *) expected="'b a' 'b a'";;
      esac
      When call sx_arg_rfind res "$target" "$flags" ::: other 'b a' '' 'b a'
      The status should be success
      The variable res should equal "$expected"
    End
  End

  Context 'コールバックの状態管理'
    Parameters:matrix
      0 1
      arith nat0
    End

    It '元の添字と右側の一致数を渡し非0は不一致として扱う'
      load_subject sx_arg_rfind
      sx_test_setup sx_cfg_set "SKIP_CHK=$1"
      select_rfind_path "$2"
      calls=''
      cb() { calls="${calls}${2}:${3};"; is_b "$1"; }
      When call sx_arg_rfind res cb 2 ::: a 'b a' c 'b a'
      The status should be success
      The variable res should equal '4 2'
      The variable calls should equal '4:0;3:1;2:1;1:2;'
    End

    It 'バインド枯渇後はコールバックを呼ばない'
      load_subject sx_arg_rfind
      sx_test_setup sx_cfg_set "SKIP_CHK=$1"
      select_rfind_path "$2"
      calls=''
      cb() { calls="${calls}${2}:${3};"; }
      When call sx_arg_rfind 'idx_a:idx_b:' cb 2 ::: a b c d
      The status should be success
      The variable idx_a should equal 4
      The variable idx_b should equal 3
      The variable calls should equal '4:0;3:1;'
    End

    It '再入しても外側の位置番号と一致数とバインドを保持する'
      load_subject sx_arg_rfind
      sx_test_setup sx_cfg_set "SKIP_CHK=$1"
      select_rfind_path "$2"
      calls=''
      inner_cb() { return 0; }
      cb() {
        sx_arg_rfind nested_result inner_cb 2 ::: x y
        calls="${calls}${2}:${3};"
        is_b "$1"
      }
      When call sx_arg_rfind res cb 2 ::: a 'b a' c 'b a'
      The status should be success
      The variable res should equal '4 2'
      The variable nested_result should equal '2 1'
      The variable calls should equal '4:0;3:1;2:1;1:2;'
    End
  End

  It '再入呼び出しが別の数値経路を選んでも外側の経路を保持する'
    load_subject sx_arg_rfind
    # 外側の最大位置11は多倍長、内側の最大位置9は算術を選ぶ。
    __sx_num_is_int_fit_dec() {
      case "${#}:${2-}" in 2:11) return 1;; esac
      return 0
    }
    calls=''
    inner_cb() { return 0; }
    cb() {
      sx_arg_rfind nested_result inner_cb 2 ::: x y
      calls="${calls}${2}:${3};"
      is_b "$1"
    }
    When call sx_arg_rfind res cb 2 ::: a 'b a' c 'b a'
    The status should be success
    The variable res should equal '4 2'
    The variable calls should equal '4:0;3:1;2:1;1:2;'
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
      load_subject sx_arg_rfind
      select_rfind_path nat0
      res=old
      never() { return 77; }
      When call sx_arg_rfind res "$2" "$1" ::: a b
      The status should equal 1
      The variable res should equal ''
    End
  End

  Context '空の入力と空のバインド'
    Parameters:matrix
      0 1
      res ''
    End

    It '数値経路を判定せず終了状態1を返す'
      load_subject sx_arg_rfind
      sx_test_setup sx_cfg_set "SKIP_CHK=$1"
      fit_called=0 called=0 res=old
      __sx_num_is_nat0_safe() { return 0; }
      __sx_num_is_int_fit_dec() { fit_called=1; return 1; }
      cb() { called=1; }
      case "$2" in '') expected=old; set -- '' cb 2 ::: a b;; *) expected=''; set -- res cb 2 :::;; esac
      When call sx_arg_rfind "$@"
      The status should equal 1
      The variable res should equal "$expected"
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
      load_subject sx_arg_rfind
      __sx_num_is_nat0_safe() { case "$1" in 6) return 1;; esac; return 0; }
      cb() { case "$1" in b) return 0;; esac; return 77; }
      When call sx_arg_rfind res "$2" "$1" ::: a b
      The status should be success
      The variable res should equal 2
    End
  End

  It 'フラグには引き続き数値範囲検証を適用する'
    load_subject sx_arg_rfind
    sx_test_setup sx_cfg_set NUM_RANGE=32
    res=old
    When call sx_arg_rfind res b 2147483648 ::: a b
    The status should equal 64
    The variable res should equal old
  End

  It '簡易形式でも多倍長経路で空要素を逆順に探す'
    load_subject sx_arg_rfind
    select_rfind_path nat0
    When call sx_arg_rfind res '' '' x ''
    The status should be success
    The variable res should equal '3 1'
  End

  Context 'TEXTモードの値の復元'
    Parameters
      5 '*'
      6 cb
    End

    It '空文字列と引用符とシェル構文を含む値を逆順で復元できる'
      load_subject sx_arg_rfind
      select_rfind_path nat0
      cb() { return 0; }
      # シェル構文は評価せず値として渡す。
      # shellcheck disable=SC2016
      payload='$(exit 99); *'
      res=''
      verify() {
        sx_arg_rfind res "$2" "$1" ::: '' 'a b' "c'd" "$payload"
        eval "set -- $res"
        [ "$#" = 4 ] && [ "$1" = "$payload" ] && [ "$2" = "c'd" ] && [ "$3" = 'a b' ] && [ "$4" = '' ]
      }
      When call verify "$1" "$2"
      The status should be success
    End
  End

  Context '8bit範囲の境界'
    Parameters:matrix
      120 121 127 128
      0 1 2 4 5 6
    End

    It '管理用の位置番号と一致数が算術域を超えても全件を逆順に検索する'
      load_subject __sx_arg_rfind
      count="$1" flags="$2" idx=0 expected=''
      set --
      while [ "$idx" -lt "$count" ]; do
        idx=$((idx + 1))
        set -- "$@" x
        case "$flags" in
          0 | 1 | 2) expected="${idx}${expected:+ }${expected}";;
          *) expected="'x'${expected:+ }${expected}";;
        esac
      done
      # 公開設定の対象外である8bit幅を内部実装の境界検証に使う。
      sx_test_setup __sx_cfg_set NUM_RANGE=8
      case "$flags" in 2 | 6) bound=120;; *) bound=127;; esac
      if [ "$count" -le "$bound" ]; then
        __sx_num_sub1_nat0() { return 64; }
        __sx_num_add1_nat0() { return 64; }
      else
        __sx_num_sub1_arith() { return 64; }
        __sx_num_add1_arith() { return 64; }
      fi
      expected_prior=$((count - 1))
      last_idx=0 last_count=0
      cb() { last_idx="$2"; last_count="$3"; case "$1" in x) return 0;; esac; return 77; }
      case "$flags" in 2 | 6) target=cb;; *) target=x;; esac
      When call __sx_arg_rfind res "$target" "$flags" ::: "$@"
      The status should be success
      The variable res should equal "$expected"
      case "$flags" in 2 | 6)
        The variable last_idx should equal 1
        The variable last_count should equal "$expected_prior"
      esac
    End
  End
End
