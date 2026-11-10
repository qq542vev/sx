#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_arg_reach'
  # Exampleごとに対象だけを読み込み、再入とスタブは検証側に残す。
  load_subject() {
    case "$1" in
      sx_arg_reach)
        sxtest_load ./build/modules/sx_arg_reach.sh
        ;;
      __sx_arg_reach)
        sxtest_load ./build/modules/__sx_arg_reach.sh
        ;;
      *) return 64;;
    esac
  }

  Include ./spec/support/run.sh

  Describe '走査順序'
    It '末尾の要素から順に処理すること'
      load_subject sx_arg_reach
      result=''
      cb() { result="${result}($1:$2)"; }
      When call sx_arg_reach cb a b c
      The status should be success
      The variable result should equal '(c:3)(b:2)(a:1)'
    End

    It '要素が1個の場合にその要素を処理すること'
      load_subject sx_arg_reach
      result=''
      cb() { result="${result}($1:$2)"; }
      When call sx_arg_reach cb only
      The status should be success
      The variable result should equal '(only:1)'
    End

    It '空のリストではコールバックを呼ばないこと'
      load_subject sx_arg_reach
      called=0
      cb() { called=1; }
      When call sx_arg_reach cb
      The status should be success
      The variable called should equal 0
    End
  End

  Describe 'インデックスの意味'
    It 'インデックスは元の引数リストにおける1-based位置であること'
      load_subject sx_arg_reach
      result=''
      cb() { result="${result}${2},"; }
      When call sx_arg_reach cb a b c d
      The status should be success
      The variable result should equal '4,3,2,1,'
    End
  End

  Describe '値の受け渡し'
    It '空白を含む値をそのまま渡すこと'
      load_subject sx_arg_reach
      result=''
      cb() { result="${result}[$1]"; }
      When call sx_arg_reach cb 'a b' c
      The status should be success
      The variable result should equal '[c][a b]'
    End

    It '引用符や特殊文字を含む値をそのまま渡すこと'
      load_subject sx_arg_reach
      result=''
      cb() { result="${result}[$1]"; }
      When call sx_arg_reach cb "c'd" 'e"f' 'g$h' 'i*j'
      The status should be success
      The variable result should equal '[i*j][g$h][e"f][c'"'"'d]'
    End

    It '空文字列の値をそのまま渡すこと'
      load_subject sx_arg_reach
      result=''
      cb() { result="${result}[$1]"; }
      When call sx_arg_reach cb '' x
      The status should be success
      The variable result should equal '[x][]'
    End
  End

  Describe 'エラー中断'
    It 'コールバックが非0を返すと即座に中断すること'
      load_subject sx_arg_reach
      result=''
      cb() {
        result="${result}($1)"
        case "$1" in b) return 7;; esac
      }
      When call sx_arg_reach cb a b c
      The status should equal 7
      The variable result should equal '(c)(b)'
    End

    It 'コールバックの終了ステータスをそのまま返すこと'
      load_subject sx_arg_reach
      cb() { return 42; }
      When call sx_arg_reach cb a
      The status should equal 42
    End
  End

  Describe '再入'
    It 'コールバックの中から reach を呼んでも外側の状態が保たれること'
      load_subject sx_arg_reach
      result=''
      inner_cb() { result="${result}<$1>"; }
      outer_cb() { result="${result}[$1:$2]"; sx_arg_reach inner_cb x y; result="${result}"; }
      When call sx_arg_reach outer_cb m n
      The status should be success
      The variable result should equal '[n:2]<y><x>[m:1]<y><x>'
    End
  End

  Describe '多倍長経路'
    It '引数個数に安全範囲の上限を適用しない'
      load_subject sx_arg_reach
      __sx_num_is_nat0_safe() { return 1; }
      result=''
      cb() { result="${result}${2}"; }
      When call sx_arg_reach cb a b c
      The status should be success
      The variable result should equal '321'
    End

    Context '算術経路と多倍長経路'
      Parameters:matrix
        0 1
        arith nat0
      End

      It '末尾から元の添字と特殊文字を含む値を渡す'
        load_subject sx_arg_reach
        sxtest_run SX_CFG_SKIP_CHK -- 'sx_cfg_set "$@"' "SKIP_CHK=$1"
        select_reach_path() {
          case "$1" in
            arith) __sx_num_sub1_nat0() { return 64; };;
            nat0)
              __sx_num_is_int_fit_dec() { return 1; }
              __sx_num_add1_arith() { return 64; }
              ;;
          esac
        }
        select_reach_path "$2"
        result=''
        cb() { result="${result}${2}:${1},"; }
        When call sx_arg_reach cb 'a b' '' "c'd"
        The status should be success
        The variable result should equal "3:c'd,2:,1:a b,"
      End

      It '再入呼び出しが別の数値経路を選んでも外側の経路を保持する'
        load_subject sx_arg_reach
        __sx_num_is_int_fit_dec() {
          case "${#}:${2-}" in 2:10) return 1;; esac
          return 0
        }
        result=''
        inner_cb() { result="${result}<$1>"; }
        outer_cb() { result="${result}[$1:$2]"; sx_arg_reach inner_cb x y; result="${result}"; }
        When call sx_arg_reach outer_cb a b c d
        The status should be success
        The variable result should equal '[d:4]<y><x>[c:3]<y><x>[b:2]<y><x>[a:1]<y><x>'
      End
    End
  End

  Context '8bit範囲の境界'
    Parameters
      126
      127
      128
    End

    It '算術域の前後で全要素を処理し末尾から元の添字を渡す'
      load_subject __sx_arg_reach
      count="$1"
      args=
      sxtest_run args -- 'sx_str_rep "$@"' args "'x' " "$count"
      expected=
      sxtest_run expected -- 'sx_str_rep "$@"' expected x "$count"
      eval "set -- $args"
      # 公開設定の対象外である8bit幅を内部実装の境界検証に使う。
      sxtest_run SX_CFG_NUM_RANGE SX_SYS_NUM_QM SX_SYS_NUM_ZR -- '__sx_cfg_set "$@"' NUM_RANGE=8
      result='' first_idx=0 last_idx=0
      cb() {
        case "$first_idx" in 0) first_idx="$2";; esac
        result="${result}${1}"
        last_idx="$2"
      }
      When call __sx_arg_reach cb "$@"
      The status should be success
      The variable result should equal "$expected"
      The variable first_idx should equal "$count"
      The variable last_idx should equal 1
    End
  End

  Describe '内部関数 (__sx_arg_reach)'
    It '__sx_arg_reach が正しく動作すること'
      load_subject __sx_arg_reach
      result=''
      cb() { result="${result}($1:$2)"; }
      When call __sx_arg_reach cb a b c
      The status should be success
      The variable result should equal '(c:3)(b:2)(a:1)'
    End
  End

  Describe '高速モード (SX_CFG_SKIP_CHK=1)'
    It 'チェックをスキップして reach すること'
      load_subject sx_arg_reach
      result=''
      cb() { result="${result}($1:$2)"; }
      SX_CFG_SKIP_CHK=1
      When call sx_arg_reach cb a b c
      The status should be success
      The variable result should equal '(c:3)(b:2)(a:1)'
    End
  End
End
