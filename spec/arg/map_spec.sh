# shellcheck shell=sh disable=SC2329
# コールバックと検証用の差し替え関数はShellSpec経由で間接的に呼び出される。

eval "$(shellspec - -c) exit 1"

Describe 'sx_arg_map'
  Include ./spec/support/library.sh spec/arg/map_spec.sh SX_CFG_SKIP_CHK SX_NUM_I8_MAX SX_NUM_I8_MIN SX_NUM_I8_QM SX_NUM_I8_WLEN SX_NUM_I8_ZR __sx_arg_map __sx_cfg_set __sx_num_add1_arith __sx_num_add1_nat0 __sx_num_is_int_fit_dec __sx_var_set sx_arg_map sx_cfg_set sx_str_rep sx_str_upper

  select_map_path() {
    case "$1" in
      arith) __sx_num_add1_nat0() { return 64; };;
      nat0)
        __sx_num_is_int_fit_dec() { return 1; }
        __sx_num_add1_arith() { return 64; }
        ;;
    esac
  }

  Context '算術経路と多倍長経路'
    Parameters
      0 arith
      0 nat0
      1 arith
      1 nat0
    End

    It '検証の有無によらず値と1-basedの添字を渡す'
      sx_cfg_set "SKIP_CHK=$1"
      select_map_path "$2"
      cb() { __sx_var_set "${1}=[${3}:${2}]"; }
      When call sx_arg_map res cb 'a b' '' "c'd"
      The status should be success
      The variable res should equal "[1:a b] [2:] [3:c'd]"
    End

    It 'スキップした要素も元の添字に含める'
      sx_cfg_set "SKIP_CHK=$1"
      select_map_path "$2"
      cb() {
        case "$2" in skip) return 0;; esac
        __sx_var_set "${1}=${3}:${2}"
      }
      When call sx_arg_map res cb a skip c
      The status should be success
      The variable res should equal '1:a 3:c'
    End

    It '最初の失敗以降は元の値を格納しコールバックを呼ばない'
      sx_cfg_set "SKIP_CHK=$1"
      select_map_path "$2"
      calls=
      cb() {
        calls="${calls}${3}:${2};"
        __sx_var_set "${1}=changed:${2}"
        case "$3" in 2) return 77;; esac
        return 0
      }
      When call sx_arg_map res cb a b c
      The status should equal 77
      The variable res should equal 'changed:a b c'
      The variable calls should equal '1:a;2:b;'
    End

    It 'バインド枯渇時は後続のコールバックを呼ばない'
      sx_cfg_set "SKIP_CHK=$1"
      select_map_path "$2"
      calls=
      cb() {
        calls="${calls}${3};"
        __sx_var_set "${1}=${3}:${2}"
      }
      When call sx_arg_map '2res:' cb a b c
      The status should be success
      The variable res should equal '1:a 2:b'
      The variable calls should equal '1;2;'
    End

    It '再入呼び出し後も外側の値と添字を保持する'
      sx_cfg_set "SKIP_CHK=$1"
      select_map_path "$2"
      inner_cb() { __sx_var_set "${1}=${3}:${2}"; }
      outer_cb() {
        sx_arg_map nested_result inner_cb "${2}x" "${2}y"
        # shellcheck disable=SC2154
        __sx_var_set "${1}=(${3}:${nested_result})"
        unset nested_result
      }
      When call sx_arg_map res outer_cb a b
      The status should be success
      The variable res should equal '(1:1:ax 2:ay) (2:1:bx 2:by)'
    End
  End

  It '再入呼び出しが別の数値経路を選んでも外側の経路を保持する'
    # 外側は5引数で多倍長、内側は3引数で算術を選ぶ。
    __sx_num_is_int_fit_dec() {
      case "${#}:${2-}" in 2:5) return 1;; esac
      return 0
    }
    inner_cb() { __sx_var_set "${1}=${3}:${2}"; }
    outer_cb() {
      sx_arg_map nested_result inner_cb "${2}x"
      # shellcheck disable=SC2154
      __sx_var_set "${1}=(${3}:${nested_result})"
      unset nested_result
    }
    When call sx_arg_map res outer_cb a b c
    The status should be success
    The variable res should equal '(1:1:ax) (2:1:bx) (3:1:cx)'
  End

  Context '8bit範囲の境界'
    Parameters
      125
      126
      127
      128
    End

    It '算術域の前後で全要素を変換し最後の添字を渡す'
      expected_idx="$1"
      args=
      sx_str_rep args "'x' " "$expected_idx"
      expected=
      sx_str_rep expected 'x ' "$expected_idx"
      expected="${expected% }"
      eval "set -- $args"
      # 公開設定の対象外である8bit幅を内部実装の境界検証に使う。
      __sx_cfg_set NUM_RANGE=8
      last_idx=0
      cb() { __sx_var_set "${1}=${2}"; last_idx="$3"; }
      When call __sx_arg_map res cb "$@"
      The status should be success
      The variable res should equal "$expected"
      The variable last_idx should equal "$expected_idx"
    End
  End

  It '空リストでは数値経路を判定せず結果を初期化する'
    fit_called=0 called=0 res=old
    __sx_num_is_int_fit_dec() { fit_called=1; return 1; }
    cb() { called=1; }
    When call sx_arg_map res cb
    The status should be success
    The variable res should equal ''
    The variable fit_called should equal 0
    The variable called should equal 0
  End

  It '空のバインドではコールバックを呼ばない'
    called=0
    cb() { called=1; }
    When call sx_arg_map '' cb a b
    The status should be success
    The variable called should equal 0
  End

  Describe 'マップ: 全要素に変換を適用'
    It '各要素を大文字に変換する'
      cb() { case $2 in a) __sx_var_set "$1=A";; b) __sx_var_set "$1=B";; c) __sx_var_set "$1=C";; esac; }
      When call sx_arg_map res cb a b c
      The status should be success
      The variable res should equal "A B C"
    End

    It '空文字列も変換対象とする'
      cb() { __sx_var_set "$1=($2)"; }
      When call sx_arg_map res cb '' foo ''
      The status should be success
      The variable res should equal "() (foo) ()"
    End
  End

  Describe 'フィルター: ret を unset でスキップ'
    It '数値のみを通す'
      filternum() { case $2 in *[!0-9]*) ;; *) __sx_var_set "$1=$2"; esac; }
      When call sx_arg_map res filternum a 42 b 7 c
      The status should be success
      The variable res should equal "42 7"
    End

    It '全てスキップすると空になる'
      skipall() { :; }
      When call sx_arg_map res skipall a b c
      The status should be success
      The variable res should equal ""
    End
  End

  Describe 'フィルター + マップ'
    It '偶数番目だけ変換する'
      even_only() { case $(($3 % 2)) in 0) sx_str_upper "$1" "$2"; esac; }
      When call sx_arg_map res even_only a b c d e
      The status should be success
      The variable res should equal "B D"
    End
  End

  Describe 'エラー回復'
    It 'cb が非0を返すと元の値をバインド、ステータスを保存'
      err_on_b() { case $2 in b) return 2;; esac; __sx_var_set "$1=$2"; }
      When call sx_arg_map res err_on_b a b c
      The status should equal 2
      The variable res should equal "a b c"
    End

    It '最初のエラーステータスが優先される'
      err_on_b_d() {
        case $2 in
          b) return 2;;
          d) return 5;;
        esac
        __sx_var_set "$1=$2"
      }
      When call sx_arg_map res err_on_b_d a b c d
      The status should equal 2
      The variable res should equal "a b c d"
    End

    It '全要素でエラーになっても元の値をバインド'
      always_err() { return 3; }
      When call sx_arg_map res always_err x y
      The status should equal 3
      The variable res should equal "x y"
    End
  End

  Describe '空リスト'
    It '引数なしで空文字列、ステータス 0'
      cb() { __sx_var_set "$1=X"; }
      When call sx_arg_map res cb
      The status should be success
      The variable res should equal ""
    End
  End

  Describe 'バインド形式'
    It 'Nname: で上限を指定できる'
      cb() { sx_str_upper "$1" "$2"; }
      When call sx_arg_map "2res:" cb a b c d
      The status should be success
      The variable res should equal "A B"
    End

    It 'v1:v2: で分配代入できる'
      cb() { sx_str_upper "$1" "$2"; }
      When call sx_arg_map "r1:r2:" cb a b c
      The status should be success
      The variable r1 should equal "A"
      The variable r2 should equal "B"
    End
  End

  Describe 'エラーケース'
    It '結果変数が読み取り専用の場合に EX_NOPERM を返す'
      cb() { __sx_var_set "$1=$2"; }
      readonly ro_map=0
      When call sx_arg_map ro_map cb a b
      The status should equal 77
    End

    It '結果変数名が無効な場合に EX_USAGE を返す'
      cb() { :; }
      When call sx_arg_map "1bad" cb a
      The status should equal 64
    End
  End

  Describe '高速モード (SX_CFG_SKIP_CHK=1)'
    It 'チェックをスキップしてマップする'
      cb() { __sx_var_set "$1=($2)"; }
      SX_CFG_SKIP_CHK=1
      When call sx_arg_map res cb a b c
      The status should be success
      The variable res should equal "(a) (b) (c)"
    End
  End

  Describe '内部関数 (__sx_arg_map)'
    It '__sx_arg_map が正しく動作する'
      cb() { __sx_var_set "$1=($2)"; }
      When call __sx_arg_map res cb a b c
      The status should be success
      The variable res should equal "(a) (b) (c)"
    End
  End

  Describe '再帰呼び出し'
    It 'arg_map 内で arg_map を呼び出しても状態が壊れない'
      inner_cb() { __sx_var_set "$1=($2)"; }
      outer_cb() {
        __sx_arg_map __sx_arg_map_tmp inner_cb "${2}x" "${2}y"
        eval "$1=\${__sx_arg_map_tmp}"
      }
      When call sx_arg_map res outer_cb a b
      The status should be success
      The variable res should equal "(ax) (ay) (bx) (by)"
    End
  End
End
