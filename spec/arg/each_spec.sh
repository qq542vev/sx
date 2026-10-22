# shellcheck shell=sh disable=SC2329
# コールバックと検証用の差し替え関数はShellSpec経由で間接的に呼び出される。

eval "$(shellspec - -c) exit 1"

Describe 'sx_arg_each'
  # Exampleごとに対象だけを読み込み、再入とスタブは検証側に残す。
  load_subject() {
    case "$1" in
      sx_arg_each)
        Include ./spec/support/library.sh sx_arg_each
        ;;
      __sx_arg_each)
        Include ./spec/support/library.sh __sx_arg_each
        ;;
      *) return 64;;
    esac
  }

  Include ./spec/support/prepare.sh

  It '引数個数に安全範囲の上限を適用しない'
    load_subject sx_arg_each
    __sx_num_is_nat0_safe() {
      case "${1-}" in 4) return 1;; esac
      return 0
    }
    result=
    cb() { result="${result}${2}:(${1})"; }
    When call sx_arg_each cb 'a b' '' "c'd"
    The status should be success
    The variable result should equal "1:(a b)2:()3:(c'd)"
  End

  It '算術域内では算術経路で添字を更新する'
    load_subject sx_arg_each
    __sx_num_add1_nat0() { return 64; }
    result=
    cb() { result="${result}${2}:${1};"; }
    When call sx_arg_each cb a b c
    The status should be success
    The variable result should equal '1:a;2:b;3:c;'
  End

  Context '多倍長経路'

    # shellcheck disable=SC2329
    force_each_multiprecision() {
      # 少数の引数で多倍長経路を選び、算術経路を使うと失敗させる。
      __sx_num_is_int_fit_dec() { return 1; }
      __sx_num_add1_arith() { return 64; }
    }

    Parameters
      0
      1
    End

    It '検証の有無によらず値と1-basedの添字を保持する'
      load_subject sx_arg_each
      force_each_multiprecision
      sx_test_setup sx_cfg_set "SKIP_CHK=$1"
      result=
      cb() { result="${result}${2}:(${1})"; }
      When call sx_arg_each cb 'a b' '' "c'd"
      The status should be success
      The variable result should equal "1:(a b)2:()3:(c'd)"
    End

    It 'コールバック失敗時は後続を処理せず終了ステータスを返す'
      load_subject sx_arg_each
      force_each_multiprecision
      sx_test_setup sx_cfg_set "SKIP_CHK=$1"
      result=
      cb() {
        result="${result}${2}:${1};"
        case "${2}" in 2) return 77;; esac
        return 0
      }
      When call sx_arg_each cb a b c
      The status should equal 77
      The variable result should equal '1:a;2:b;'
    End

    It '再入呼び出し後も外側の値と添字を保持する'
      load_subject sx_arg_each
      force_each_multiprecision
      sx_test_setup sx_cfg_set "SKIP_CHK=$1"
      result=
      inner_cb() { result="${result}${2}:${1};"; }
      outer_cb() {
        result="${result}${2}:${1}["
        sx_arg_each inner_cb x y
        result="${result}]${2}:${1};"
      }
      When call sx_arg_each outer_cb a b
      The status should be success
      The variable result should equal '1:a[1:x;2:y;]1:a;2:b[1:x;2:y;]2:b;'
    End
  End

  It '再入呼び出しが別の数値経路を選んでも外側の経路を保持する'
    load_subject sx_arg_each
    # 外側は4引数で多倍長、内側は3引数で算術を選ぶ。
    __sx_num_is_int_fit_dec() {
      case "${#}:${2-}" in 2:4) return 1;; esac
      return 0
    }
    result=
    inner_cb() { result="${result}${2}:${1};"; }
    outer_cb() {
      result="${result}${2}:${1}["
      sx_arg_each inner_cb x y
      result="${result}]${2}:${1};"
    }
    When call sx_arg_each outer_cb a b c
    The status should be success
    The variable result should equal '1:a[1:x;2:y;]1:a;2:b[1:x;2:y;]2:b;3:c[1:x;2:y;]3:c;'
  End

  Context '8bit範囲の境界'
    Parameters
      126
      127
      128
    End

    It '算術域の前後で全要素を処理し最後の添字を渡す'
      load_subject __sx_arg_each
      expected_idx="$1"
      args=
      sx_test_setup sx_str_rep args "'x' " "$expected_idx"
      expected=
      sx_test_setup sx_str_rep expected x "$expected_idx"
      eval "set -- $args"
      # 公開設定の対象外である8bit幅を内部実装の境界検証に使う。
      sx_test_setup __sx_cfg_set NUM_RANGE=8
      result='' last_idx=0
      cb() { result="${result}${1}"; last_idx="$2"; }
      When call __sx_arg_each cb "$@"
      The status should be success
      The variable result should equal "$expected"
      The variable last_idx should equal "$expected_idx"
    End
  End

  It '空リストでは数値経路を判定しない'
    load_subject sx_arg_each
    __sx_num_is_int_fit_dec() { return 64; }
    called=0
    cb() { called=1; }
    When call sx_arg_each cb
    The status should be success
    The variable called should equal 0
  End

  It 'コールバック引数もない場合は何もせず成功する'
    load_subject sx_arg_each
    When call sx_arg_each
    The status should be success
  End

  It '数値範囲設定が不正な場合はコールバックを呼ばずEX_CONFIGを返す'
    load_subject sx_arg_each
    SX_CFG_NUM_RANGE=bogus
    called=0
    cb() { called=1; }
    When call sx_arg_each cb a
    The status should equal 78
    The variable called should equal 0
  End

  Describe '基本: 各要素に副作用を適用'
    It '各要素を別の変数に追記する'
      load_subject sx_arg_each
      result=
      cb() { result="${result}($1)"; }
      When call sx_arg_each cb a b c
      The status should be success
      The variable result should equal "(a)(b)(c)"
    End

    It '空文字列も処理対象とする'
      load_subject sx_arg_each
      result=
      cb() { result="${result}($1)"; }
      When call sx_arg_each cb '' foo ''
      The status should be success
      The variable result should equal "()(foo)()"
    End
  End

  Describe 'インデックス'
    It 'インデックスが 1-based で渡る'
      load_subject sx_arg_each
      result=
      cb() { result="${result}$2:"; }
      When call sx_arg_each cb a b c
      The status should be success
      The variable result should equal "1:2:3:"
    End
  End

  Describe '空リスト'
    It '引数なしでコールバックは呼ばれない'
      load_subject sx_arg_each
      called=0
      cb() { : $((called += 1)); }
      When call sx_arg_each cb
      The status should be success
      The variable called should equal 0
    End
  End

  Describe 'エラー中断'
    It 'cb が非0を返すと即座に中断する'
      load_subject sx_arg_each
      result=
      cb() {
        case $1 in
          b) return 2;;
          *) result="${result}($1)";;
        esac
      }
      When call sx_arg_each cb a b c d
      The status should equal 2
      The variable result should equal "(a)"
    End

    It '最初の要素のエラーが即座に返る'
      load_subject sx_arg_each
      always_err() { return 3; }
      When call sx_arg_each always_err x y
      The status should equal 3
    End
  End

  Describe '高速モード (SX_CFG_SKIP_CHK=1)'
    It 'チェックをスキップして each する'
      load_subject sx_arg_each
      result=
      cb() { result="${result}($1)"; }
      SX_CFG_SKIP_CHK=1
      When call sx_arg_each cb a b c
      The status should be success
      The variable result should equal "(a)(b)(c)"
    End
  End

  Describe '内部関数 (__sx_arg_each)'
    It '__sx_arg_each が正しく動作する'
      load_subject __sx_arg_each
      result=
      cb() { result="${result}($1)"; }
      When call __sx_arg_each cb a b c
      The status should be success
      The variable result should equal "(a)(b)(c)"
    End
  End

  Describe '再帰呼び出し'
    It 'each 内で each を呼び出しても状態が壊れない'
      load_subject sx_arg_each
      result=
      inner_cb() { :; }
      outer_cb() {
        __sx_arg_each inner_cb "${1}x" "${1}y"
        result="${result}[$1]"
      }
      When call sx_arg_each outer_cb a b
      The status should be success
      The variable result should equal "[a][b]"
    End
  End
End
