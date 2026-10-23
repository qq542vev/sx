# shellcheck disable=SC2016 # CMD内の変数は準備用シェルで展開する。
# shellcheck shell=sh disable=SC2329
# コールバックと検証用の差し替え関数は間接的に呼び出される。

eval "$(shellspec - -c) exit 1"

Describe 'sx_arg_pad 多倍長対応'
  # Exampleごとに対象だけを読み込み、再入とスタブは検証側に残す。
  load_subject() {
    case "$1" in
      sx_arg_pad)
        Include ./spec/support/library.sh sx_arg_pad
        ;;
      __sx_arg_pad)
        Include ./spec/support/library.sh __sx_arg_pad
        ;;
      *) return 64;;
    esac
  }
  Include ./spec/support/setup.sh

  select_pad_path() {
    case "$1" in
      arith)
        __sx_num_add1_nat0() { return 64; }
        __sx_num_sub1_nat0() { return 64; }
        ;;
      nat0)
        # フラグ検証からの範囲判定を分離し、処理の経路だけを切り替える。
        __sx_num_is_int_safe_inv() { return 0; }
        __sx_num_is_int_fit_dec() { return 1; }
        __sx_num_add1_arith() { return 64; }
        __sx_num_sub1_arith() { return 64; }
        ;;
    esac
  }

  Context '算術経路と多倍長経路'
    Parameters:matrix
      0 1
      arith nat0
      left right
    End

    It '検証の有無によらず指定した側をリテラルで埋める'
      load_subject sx_arg_pad
      sxtest_setup SX_CFG_SKIP_CHK -- 'sx_cfg_set "$@"' "SKIP_CHK=$1"
      select_pad_path "$2"
      case "$3" in
        left) len=-4 expected="'p p' 'p p' 'a' 'b'";;
        right) len=+4 expected="'a' 'b' 'p p' 'p p'";;
      esac
      When call sx_arg_pad res "$len" 'p p' ::: a b
      The status should be success
      The variable res should equal "$expected"
    End

    It 'スキップ時は出力位置を保持しスロット番号とスキップ数を進める'
      load_subject sx_arg_pad
      sxtest_setup SX_CFG_SKIP_CHK -- 'sx_cfg_set "$@"' "SKIP_CHK=$1"
      select_pad_path "$2"
      case "$3" in
        left)
          len=-5 expected="'[1:2:1]' '[2:3:1]' 'a' 'b'"
          expected_calls='1:1:0;1:2:1;2:3:1;'
          ;;
        right)
          len=5 expected="'a' 'b' '[3:2:1]' '[4:3:1]'"
          expected_calls='3:1:0;3:2:1;4:3:1;'
          ;;
      esac
      calls=''
      cb() {
        calls="${calls}${2}:${3}:${4};"
        case "$3" in 1) unset "$1";; *) sxtest_setup "${1}" -- 'sx_var_set "$@"' "${1}=[${2}:${3}:${4}]";; esac
      }
      When call sx_arg_pad res "$len" cb 1 ::: a b
      The status should be success
      The variable res should equal "$expected"
      The variable calls should equal "$expected_calls"
    End

    It 'コールバック失敗時の値を捨て終了状態と元の値を保持する'
      load_subject sx_arg_pad
      sxtest_setup SX_CFG_SKIP_CHK -- 'sx_cfg_set "$@"' "SKIP_CHK=$1"
      select_pad_path "$2"
      case "$3" in
        left) len=-5 expected="'p' 'a' 'b'";;
        right) len=5 expected="'a' 'b' 'p'";;
      esac
      calls=0
      cb() {
        calls=$((calls + 1))
        case "$3" in 2) sxtest_setup "${1}" -- 'sx_var_set "$@"' "${1}=discard"; return 77;; esac
        sxtest_setup "${1}" -- 'sx_var_set "$@"' "${1}=p"
      }
      When call sx_arg_pad res "$len" cb 1 ::: a b
      The status should equal 77
      The variable res should equal "$expected"
      The variable calls should equal 2
    End

    It '設定された空文字列はスキップせず値として結合する'
      load_subject sx_arg_pad
      sxtest_setup SX_CFG_SKIP_CHK -- 'sx_cfg_set "$@"' "SKIP_CHK=$1"
      select_pad_path "$2"
      case "$3" in
        left) len=-3 expected="'' '' 'a'";;
        right) len=3 expected="'a' '' ''";;
      esac
      cb() { sxtest_setup "${1}" -- 'sx_var_set "$@"' "${1}="; }
      When call sx_arg_pad res "$len" cb 1 ::: a
      The status should be success
      The variable res should equal "$expected"
    End

    It 'バインド枯渇後はコールバックも元の値の処理も進めない'
      load_subject sx_arg_pad
      sxtest_setup SX_CFG_SKIP_CHK -- 'sx_cfg_set "$@"' "SKIP_CHK=$1"
      select_pad_path "$2"
      case "$3" in
        left) len=-5 expected_calls=2 expected_a=p expected_b=p;;
        right) len=5 expected_calls=1 expected_a=a expected_b=p;;
      esac
      calls=0
      cb() { calls=$((calls + 1)); sxtest_setup "${1}" -- 'sx_var_set "$@"' "${1}=p"; }
      When call sx_arg_pad 'item_a:item_b:' "$len" cb 1 ::: a
      The status should be success
      The variable item_a should equal "$expected_a"
      The variable item_b should equal "$expected_b"
      The variable calls should equal "$expected_calls"
    End

    It '再入の結果を末尾で代入しても内外の結果を保持する'
      load_subject sx_arg_pad
      sxtest_setup SX_CFG_SKIP_CHK -- 'sx_cfg_set "$@"' "SKIP_CHK=$1"
      select_pad_path "$2"
      side="$3" res=''
      case "$side" in left) len=-4;; *) len=4;; esac
      inner_cb() { sxtest_setup "${1}" -- 'sx_var_set "$@"' "${1}=inner"; }
      cb() {
        sx_arg_pad nested_result 2 inner_cb 1 ::: z
        eval "${1}=\${nested_result}"
      }
      verify() {
        sx_arg_pad res "$len" cb 1 ::: a b
        eval "set -- $res"
        [ "$#" = 4 ] || return 1
        case "$side" in
          left)
            [ "$1" = "'z' 'inner'" ] && [ "$2" = "$1" ] && [ "$3" = a ] && [ "$4" = b ] || return 1
            nested="$1"
            ;;
          right)
            [ "$1" = a ] && [ "$2" = b ] && [ "$3" = "'z' 'inner'" ] && [ "$4" = "$3" ] || return 1
            nested="$3"
            ;;
        esac
        eval "set -- $nested"
        [ "$#" = 2 ] && [ "$1" = z ] && [ "$2" = inner ]
      }
      When call verify
      The status should be success
    End
  End

  It '再入呼び出しが別の数値経路を選んでも外側のカウンタを保持する'
    load_subject sx_arg_pad
    __sx_num_is_int_fit_dec() {
      case "${#}:${2-}:${3-}" in 3:4:2) return 1;; esac
      return 0
    }
    calls=''
    inner_cb() { sxtest_setup "${1}" -- 'sx_var_set "$@"' "${1}=inner"; }
    cb() {
      calls="${calls}${2}:${3}:${4};"
      sx_arg_pad nested_result 2 inner_cb 1 ::: z
      eval "${1}=\${nested_result}"
    }
    When call sx_arg_pad res 4 cb 1 ::: a b
    The status should be success
    The variable calls should equal '3:1:0;4:2:0;'
  End

  It '複数段再入の結果を末尾で代入しても各段の部分結果を保持する'
    load_subject sx_arg_pad
    depth=2 res=''
    cb() {
      case "$depth" in
        0) sxtest_setup "${1}" -- 'sx_var_set "$@"' "${1}=leaf";;
        *)
          set -- "$1" "nested_result_$depth"
          depth=$((depth - 1))
          sx_arg_pad "$2" 2 cb 1 ::: z
          depth=$((depth + 1))
          eval 'set -- "$1" "${'"$2"'}" "$2"'
          unset "$3"
          eval "${1}=\${2}"
          ;;
      esac
    }
    verify() {
      sx_arg_pad res 2 cb 1 ::: a
      eval "set -- $res"
      [ "$#" = 2 ] && [ "$1" = a ] || return 1
      eval "set -- $2"
      [ "$#" = 2 ] && [ "$1" = z ] || return 1
      eval "set -- $2"
      [ "$#" = 2 ] && [ "$1" = z ] && [ "$2" = leaf ]
    }
    When call verify
    The status should be success
  End

  It '再入の結果を採用せず末尾で外側のコールバック結果を代入する'
    load_subject sx_arg_pad
    inner_cb() { sxtest_setup "${1}" -- 'sx_var_set "$@"' "${1}=inner"; }
    cb() {
      sx_arg_pad nested_result 2 inner_cb 1 ::: z
      eval "${1}=outer"
    }
    When call sx_arg_pad res 2 cb 1 ::: a
    The status should be success
    The variable res should equal "'a' 'outer'"
    The variable nested_result should equal "'z' 'inner'"
  End

  Context 'ネイティブ算術域を超える長さ'
    Parameters
      9223372036854775808
      +18446744073709551616
      # shellcheck disable=SC2215
      -9223372036854775808
    End

    It 'リテラルではバインド枯渇時に終了する'
      load_subject sx_arg_pad
      case "$1" in -*) expected="'p' 'p'";; *) expected="'a' 'p'";; esac
      When call sx_arg_pad '2res:' "$1" p ::: a
      The status should be success
      The variable res should equal "$expected"
    End

    It 'コールバックでは失敗時に終了し部分的な結果を保持する'
      load_subject sx_arg_pad
      case "$1" in -*) expected="'p' 'a'";; *) expected="'a' 'p'";; esac
      cb() { case "$3" in 2) return 77;; esac; sxtest_setup "${1}" -- 'sx_var_set "$@"' "${1}=p"; }
      When call sx_arg_pad res "$1" cb 1 ::: a
      The status should equal 77
      The variable res should equal "$expected"
    End
  End

  Context '長さの形式検証'
    Parameters
      64 ''
      64 abc
      64 010
      64 0x10
      64 -01
      64 +03
      64 1.0
      64 '1+1'
    End

    It '10進整数以外を拒否し結果変数を変更しない'
      load_subject sx_arg_pad
      res=old
      When call sx_arg_pad res "$2" p ::: a
      The status should equal "$1"
      The variable res should equal old
    End
  End

  It 'フラグには引き続き数値範囲検証を適用する'
    load_subject sx_arg_pad
    sxtest_setup SX_CFG_NUM_RANGE SX_SYS_NUM_QM SX_SYS_NUM_ZR -- 'sx_cfg_set "$@"' NUM_RANGE=32
    res=old
    When call sx_arg_pad res 9223372036854775808 p 2147483648 ::: a
    The status should equal 64
    The variable res should equal old
  End

  Context '長さ0'
    Parameters:matrix
      0 +0 -0
      0 1
    End

    It '入力値をそのまま保持しコールバックを呼ばない'
      load_subject sx_arg_pad
      called=0
      cb() { called=1; return 77; }
      case "$2" in 0) val=p;; *) val=cb;; esac
      When call sx_arg_pad res "$1" "$val" "$2" ::: '' 'a b'
      The status should be success
      The variable res should equal "'' 'a b'"
      The variable called should equal 0
    End
  End

  Context '8bit範囲の境界'
    Parameters:matrix
      127 128 129
      left right
      0 1
    End

    It '算術域の前後で末尾の余分な加算をせず全スロットを埋める'
      load_subject __sx_arg_pad
      count="$1" side="$2" flag="$3" expected='' idx=0
      while [ "$idx" -lt "$count" ]; do
        idx=$((idx + 1))
        expected="${expected}${expected:+ }'p'"
      done
      sxtest_setup SX_CFG_NUM_RANGE SX_SYS_NUM_QM SX_SYS_NUM_ZR -- '__sx_cfg_set "$@"' NUM_RANGE=8
      case "$count" in
        127) __sx_num_add1_nat0() { return 64; }; __sx_num_sub1_nat0() { return 64; };;
        *) __sx_num_add1_arith() { return 64; }; __sx_num_sub1_arith() { return 64; };;
      esac
      last_idx=0 last_cnt=0 last_skip=0
      cb() { last_idx="$2"; last_cnt="$3"; last_skip="$4"; sxtest_setup "${1}" -- 'sx_var_set "$@"' "${1}=p"; }
      case "$side" in left) len="-$count";; *) len="$count";; esac
      case "$flag" in 0) val=p;; *) val=cb;; esac
      When call __sx_arg_pad res "$len" "$val" "$flag" :::
      The status should be success
      The variable res should equal "$expected"
      case "$flag" in 1)
        The variable last_idx should equal "$count"
        The variable last_cnt should equal "$count"
        The variable last_skip should equal 0
      esac
    End
  End

  Context '元の個数が算術域の上端付近'
    Parameters:matrix
      127 128
      left right
    End

    It '元の値を保持し必要な場合だけ1スロットを追加する'
      load_subject __sx_arg_pad
      count="$1" side="$2" expected='' idx=0
      set --
      while [ "$idx" -lt "$count" ]; do
        idx=$((idx + 1))
        set -- "$@" a
        expected="${expected}${expected:+ }'a'"
      done
      case "$count:$side" in
        127:left) len=-128 expected="'p' $expected" expected_calls=1 expected_idx=1;;
        127:right) len=128 expected="$expected 'p'" expected_calls=1 expected_idx=128;;
        128:left) len=-127 expected_calls=0 expected_idx=0;;
        128:right) len=127 expected_calls=0 expected_idx=0;;
      esac
      sxtest_setup SX_CFG_NUM_RANGE SX_SYS_NUM_QM SX_SYS_NUM_ZR -- '__sx_cfg_set "$@"' NUM_RANGE=8
      __sx_num_add1_arith() { return 64; }
      __sx_num_sub1_arith() { return 64; }
      calls=0 last_idx=0
      cb() { calls=$((calls + 1)); last_idx="$2"; sxtest_setup "${1}" -- 'sx_var_set "$@"' "${1}=p"; }
      When call __sx_arg_pad res "$len" cb 1 ::: "$@"
      The status should be success
      The variable res should equal "$expected"
      The variable calls should equal "$expected_calls"
      The variable last_idx should equal "$expected_idx"
    End
  End

  Context 'スキップ数が算術域を超える場合'
    Parameters
      # shellcheck disable=SC2215
      -129
      129
    End

    It 'スキップ数128とスロット番号129を正しく渡す'
      load_subject __sx_arg_pad
      len="$1"
      sxtest_setup SX_CFG_NUM_RANGE SX_SYS_NUM_QM SX_SYS_NUM_ZR -- '__sx_cfg_set "$@"' NUM_RANGE=8
      __sx_num_add1_arith() { return 64; }
      __sx_num_sub1_arith() { return 64; }
      cb() { case "$3" in 129) sxtest_setup "${1}" -- 'sx_var_set "$@"' "${1}=${2}:${3}:${4}";; *) unset "$1";; esac; }
      When call __sx_arg_pad res "$len" cb 1 :::
      The status should be success
      The variable res should equal "'1:129:128'"
    End
  End
End
