# shellcheck disable=SC2016 # CMD内の変数は準備用シェルで展開する。
# shellcheck shell=sh disable=SC2329
# 検証用の差し替え関数は間接的に呼び出される。

eval "$(shellspec - -c) exit 1"

Describe 'sx_arg_rquote 多倍長対応'
  # Exampleごとに対象だけを読み込む。IncludeはExampleの外で宣言する。
  load_subject() {
    case "$1" in
      sx_arg_rquote)
        Include ./spec/support/library.sh sx_arg_rquote
        ;;
      __sx_arg_rquote)
        Include ./spec/support/library.sh __sx_arg_rquote
        ;;
      *) return 64;;
    esac
  }

  Include ./spec/support/run.sh

  select_rquote_path() {
    case "$1" in
      arith) __sx_num_sub1_nat0() { return 64; };;
      nat0)
        __sx_num_is_int_fit_dec() { return 1; }
        __sx_num_sub1_arith() { return 64; }
        ;;
    esac
  }

  It '引数個数に安全範囲の上限を適用しない'
    load_subject sx_arg_rquote
    __sx_num_is_nat0_safe() { return 1; }
    When call sx_arg_rquote res a b c
    The status should be success
    The variable res should equal "'c' 'b' 'a'"
  End

  Context '算術経路と多倍長経路'
    Parameters:matrix
      0 1
      arith nat0
    End

    It '検証の有無によらず特殊文字と空要素を逆順で復元できる'
      load_subject sx_arg_rquote
      sxtest_run SX_CFG_SKIP_CHK -- 'sx_cfg_set "$@"' "SKIP_CHK=$1"
      select_rquote_path "$2"
      # シェル構文は評価せず値として渡す。
      # shellcheck disable=SC2016
      payload='$(exit 99); *'
      res=''
      verify() {
        sx_arg_rquote res '' 'a b' "c'd" 'back\slash' "$payload"
        eval "set -- $res"
        [ "$#" = 5 ] && [ "$1" = "$payload" ] && [ "$2" = 'back\slash' ] &&
          [ "$3" = "c'd" ] && [ "$4" = 'a b' ] && [ "$5" = '' ]
      }
      When call verify
      The status should be success
    End

    It '逆順で分配し空要素もスキップと蓄積の対象にする'
      load_subject sx_arg_rquote
      sxtest_run SX_CFG_SKIP_CHK -- 'sx_cfg_set "$@"' "SKIP_CHK=$1"
      select_rquote_path "$2"
      When call sx_arg_rquote 'item_a::item_b' a 'b b' '' d
      The status should be success
      The variable item_a should equal d
      The variable item_b should equal "'b b' 'a'"
    End

    It 'バインド枯渇時に残りの要素を処理しない'
      load_subject sx_arg_rquote
      sxtest_run SX_CFG_SKIP_CHK -- 'sx_cfg_set "$@"' "SKIP_CHK=$1"
      select_rquote_path "$2"
      When call sx_arg_rquote 'item_a:item_b:' a 'b b' '' d
      The status should be success
      The variable item_a should equal d
      The variable item_b should equal ''
    End
  End

  Context '空リストと空バインド'
    Parameters:matrix
      0 1
      res ''
    End

    It '数値経路を判定せず初期化して成功する'
      load_subject sx_arg_rquote
      sxtest_run SX_CFG_SKIP_CHK -- 'sx_cfg_set "$@"' "SKIP_CHK=$1"
      bind="$2" res=old fit_called=0
      __sx_num_is_int_fit_dec() { fit_called=1; return 1; }
      __sx_num_sub1_arith() { return 64; }
      __sx_num_sub1_nat0() { return 64; }
      case "$bind" in '') expected=old; set -- '' a b;; *) expected=''; set -- res;; esac
      When call sx_arg_rquote "$@"
      The status should be success
      The variable res should equal "$expected"
      The variable fit_called should equal 0
    End
  End

  It '件数指定のバインドでは指定件数だけを蓄積する'
    load_subject sx_arg_rquote
    When call sx_arg_rquote '2res:' a 'b b' '' d
    The status should be success
    The variable res should equal "'d' ''"
  End

  Context '8bit範囲の境界'
    Parameters
      99
      100
      127
      128
    End

    It '算術域の前後と桁の借りで全要素を逆順に取得する'
      load_subject __sx_arg_rquote
      count="$1" idx=0 expected=''
      set --
      while [ "$idx" -lt "$count" ]; do
        idx=$((idx + 1))
        set -- "$@" "value$idx"
        expected="'value$idx'${expected:+ }${expected}"
      done
      # 公開設定の対象外である8bit幅を内部実装の境界検証に使う。
      sxtest_run SX_CFG_NUM_RANGE SX_SYS_NUM_QM SX_SYS_NUM_ZR -- '__sx_cfg_set "$@"' NUM_RANGE=8
      case "$count" in
        128) __sx_num_sub1_arith() { return 64; };;
        *) __sx_num_sub1_nat0() { return 64; };;
      esac
      When call __sx_arg_rquote res "$@"
      The status should be success
      The variable res should equal "$expected"
    End
  End

  It '不正な数値範囲設定は引き続き拒否する'
    load_subject sx_arg_rquote
    SX_CFG_NUM_RANGE=bogus
    res=old
    When call sx_arg_rquote res a b
    The status should equal 78
    The variable res should equal old
  End

  It '不正な結果変数名は引き続き拒否する'
    load_subject sx_arg_rquote
    When call sx_arg_rquote 'bad-name' a b
    The status should equal 64
  End
End
