# shellcheck shell=sh disable=SC2329
# コールバックと経路検証用の差し替え関数は間接的に呼び出される。

eval "$(shellspec - -c) exit 1"

Describe 'sx_arg_isep 多倍長対応'
  # Exampleごとに対象だけを読み込み、再入とスタブは検証側に残す。
  load_subject() {
    case "$1" in
      sx_arg_isep)
        Include ./spec/support/library.sh sx_arg_isep
        ;;
      __sx_arg_isep)
        Include ./spec/support/library.sh __sx_arg_isep
        ;;
      *) return 64;;
    esac
  }

  Include ./spec/support/prepare.sh

  select_isep_path() {
    case "$1" in
      arith)
        __sx_num_add1_nat0() { return 64; }
        __sx_num_sub1_nat0() { return 64; }
        ;;
      nat0)
        __sx_num_is_nat0_safe() { return 0; }
        # isep の複数入力の判定だけを範囲外とする。
        # 除算内部の単一値判定は、小さい被演算子に本来の算術経路を使わせる。
        __sx_num_is_int_fit_dec() { case "$#" in 2) return 0;; *) return 1;; esac; }
        __sx_num_add1_arith() { return 64; }
        __sx_num_sub1_arith() { return 64; }
        ;;
    esac
  }

  Context '算術経路と多倍長経路'
    Parameters:matrix
      0 1
      arith nat0
      2 -2
    End

    It '両端と内部の境界に挿入する'
      load_subject sx_arg_isep
      sx_test_setup sx_cfg_set "SKIP_CHK=$1"
      select_isep_path "$2"
      When call sx_arg_isep res p "$3" '' 6 ::: a b c d
      The status should be success
      The variable res should equal "'p' 'a' 'b' 'p' 'c' 'd' 'p'"
    End

    It '上限を走査方向から数えPRE/POSTにも適用する'
      load_subject sx_arg_isep
      sx_test_setup sx_cfg_set "SKIP_CHK=$1"
      select_isep_path "$2"
      case "$3" in
        2) expected="'p' 'a' 'b' 'p' 'c' 'd'";;
        -2) expected="'a' 'b' 'p' 'c' 'd' 'p'";;
      esac
      When call sx_arg_isep res p "$3" 2 6 ::: a b c d
      The status should be success
      The variable res should equal "$expected"
    End

    It '未設定の結果は省略し境界番号・回数・スキップ数を保持する'
      load_subject sx_arg_isep
      sx_test_setup sx_cfg_set "SKIP_CHK=$1"
      select_isep_path "$2"
      case "$3" in
        2) expected_calls='0:1:0;2:2:1;4:3:1;' ;;
        -2) expected_calls='4:1:0;2:2:1;0:3:1;' ;;
      esac
      calls=''
      cb() {
        calls="${calls}${2}:${3}:${4};"
        case "$3" in 2) sx_test_setup sx_var_set "${1}=[${2}:${3}:${4}]";; *) unset "$1";; esac
      }
      When call sx_arg_isep res cb "$3" '' 7 ::: a b c d
      The status should be success
      The variable res should equal "'a' 'b' '[2:2:1]' 'c' 'd'"
      The variable calls should equal "$expected_calls"
    End

    It '成功時の空文字列を挿入する'
      load_subject sx_arg_isep
      sx_test_setup sx_cfg_set "SKIP_CHK=$1"
      select_isep_path "$2"
      cb() { sx_test_setup sx_var_set "${1}="; }
      When call sx_arg_isep res cb "$3" '' 7 ::: a b
      The status should be success
      The variable res should equal "'' 'a' 'b' ''"
    End

    It '失敗した回の結果を破棄し元の値と直前までの挿入を保持する'
      load_subject sx_arg_isep
      sx_test_setup sx_cfg_set "SKIP_CHK=$1"
      select_isep_path "$2"
      case "$3" in
        2) expected="'p' 'a' 'b' 'c' 'd'";;
        -2) expected="'a' 'b' 'c' 'd' 'p'";;
      esac
      cb() { sx_test_setup sx_var_set "${1}=p"; case "$3" in 2) return 77;; esac; }
      When call sx_arg_isep res cb "$3" '' 7 ::: a b c d
      The status should equal 77
      The variable res should equal "$expected"
    End

    It 'スキップ後の失敗でも元の値を欠落させない'
      load_subject sx_arg_isep
      sx_test_setup sx_cfg_set "SKIP_CHK=$1"
      select_isep_path "$2"
      cb() { case "$3" in 1) unset "$1";; *) sx_test_setup sx_var_set "${1}=discard"; return 77;; esac; }
      When call sx_arg_isep res cb "$3" '' 7 ::: a b c d
      The status should equal 77
      The variable res should equal "'a' 'b' 'c' 'd'"
    End

    It 'バインド枯渇時も方向ごとのコールバック実行順を保持する'
      load_subject sx_arg_isep
      sx_test_setup sx_cfg_set "SKIP_CHK=$1"
      select_isep_path "$2"
      case "$3" in 2) expected_calls=1;; -2) expected_calls=3;; esac
      calls=0
      cb() { calls=$((calls + 1)); sx_test_setup sx_var_set "${1}=p"; }
      When call sx_arg_isep 'item_a:item_b:' cb "$3" '' 7 ::: a b c d
      The status should be success
      The variable item_a should equal p
      The variable item_b should equal a
      The variable calls should equal "$expected_calls"
    End

    It '逆方向の再入呼び出し後も外側の状態を保持する'
      load_subject sx_arg_isep
      sx_test_setup sx_cfg_set "SKIP_CHK=$1"
      select_isep_path "$2"
      direction="$3" calls=''
      case "$direction" in
        2) inner_direction=-1 expected_calls='0:1:0;2:2:0;4:3:0;' ;;
        -2) inner_direction=1 expected_calls='4:1:0;2:2:0;0:3:0;' ;;
      esac
      inner_cb() { sx_test_setup sx_var_set "${1}=inner"; }
      cb() {
        calls="${calls}${2}:${3}:${4};"
        sx_arg_isep nested_result inner_cb "$inner_direction" '' 1 ::: x y
        eval "${1}=\${nested_result}"
      }
      verify() {
        sx_arg_isep res cb "$direction" '' 7 ::: a b c d
        eval "set -- $res"
        [ "$#" = 7 ] && [ "$1" = "'x' 'inner' 'y'" ] && [ "$2" = a ] &&
          [ "$3" = b ] && [ "$4" = "$1" ] && [ "$5" = c ] &&
          [ "$6" = d ] && [ "$7" = "$1" ]
      }
      When call verify
      The status should be success
      The variable calls should equal "$expected_calls"
    End

    It '特殊文字を含む元の値とコールバック結果を再評価せず保持する'
      load_subject sx_arg_isep
      sx_test_setup sx_cfg_set "SKIP_CHK=$1"
      select_isep_path "$2"
      direction="$3"
      # shellcheck disable=SC2016
      payload='$(exit 99); * " back\slash'
      payload="${payload}'"
      cb() { eval "${1}=\${payload}"; }
      verify() {
        sx_arg_isep res cb "$direction" '' 7 ::: '' "$payload"
        eval "set -- $res"
        [ "$#" = 4 ] && [ "$1" = "$payload" ] && [ "$2" = '' ] &&
          [ "$3" = "$payload" ] && [ "$4" = "$payload" ]
      }
      When call verify
      The status should be success
    End
  End

  Context 'ネイティブ算術域を超える間隔'
    Parameters:matrix
      9223372036854775808 +18446744073709551616 -9223372036854775808 -18446744073709551616
      0 1
    End

    It '走査開始端だけを処理し巨大な間隔を算術展開に渡さない'
      load_subject sx_arg_isep
      interval="$1" mode="$2" calls=0
      case "$interval" in -*) expected="'a' 'b' 'p'" expected_slot=2;; *) expected="'p' 'a' 'b'" expected_slot=0;; esac
      cb() { calls=$((calls + 1)); slot="$2"; sx_test_setup sx_var_set "${1}=p"; }
      case "$mode" in 0) sep=p flag=6;; 1) sep=cb flag=7;; esac
      When call sx_arg_isep res "$sep" "$interval" '' "$flag" ::: a b
      The status should be success
      The variable res should equal "$expected"
      case "$mode" in 1)
        The variable calls should equal 1
        The variable slot should equal "$expected_slot"
      esac
    End
  End

  Context 'ネイティブ算術域を超える上限'
    Parameters:matrix
      9223372036854775808 10000000000000000000000000000000000000000
      2 -2
      0 1
    End

    It '実際の境界数で終了する'
      load_subject sx_arg_isep
      cb() { sx_test_setup sx_var_set "${1}=p"; }
      case "$3" in 0) sep=p flag=6;; 1) sep=cb flag=7;; esac
      When call sx_arg_isep res "$sep" "$2" "$1" "$flag" ::: a b c d
      The status should be success
      The variable res should equal "'p' 'a' 'b' 'p' 'c' 'd' 'p'"
    End
  End

  Context '空リストの開始端'
    Parameters:matrix
      9223372036854775808 -9223372036854775808
      0 1
    End

    It 'PRE/POSTを重複させず境界0で1回だけ挿入する'
      load_subject sx_arg_isep
      cb() { sx_test_setup sx_var_set "${1}=${2}:${3}:${4}"; }
      case "$2" in 0) sep=0:1:0 flag=6;; 1) sep=cb flag=7;; esac
      When call sx_arg_isep res "$sep" "$1" '' "$flag" :::
      The status should be success
      The variable res should equal "'0:1:0'"
    End
  End

  Context '処理不要な入力'
    Parameters:matrix
      0 1
      empty_bind zero_limit
    End

    It '数値経路の判定とコールバックを行わない'
      load_subject sx_arg_isep
      sx_test_setup sx_cfg_set "SKIP_CHK=$1"
      case "$2" in
        empty_bind) bind='' limit='' expected=old;;
        zero_limit) bind=res limit=0 expected="'a' 'b'";;
      esac
      res=old fit_called=0 called=0
      # 公開フラグ検証からの呼び出しを分離する。
      __sx_num_is_nat0_safe() { return 0; }
      __sx_num_is_int_fit_dec() { fit_called=1; return 1; }
      cb() { called=1; return 77; }
      When call sx_arg_isep "$bind" cb 9223372036854775808 "$limit" 7 ::: a b
      The status should be success
      The variable res should equal "$expected"
      The variable fit_called should equal 0
      The variable called should equal 0
    End
  End

  Context '10進表記の検証'
    Parameters
      0 ''
      +0 ''
      # shellcheck disable=SC2215
      -0 ''
      01 ''
      # shellcheck disable=SC2215
      -01 ''
      +01 ''
      0x10 ''
      '1+1' ''
      abc ''
      1 01
      1 +1
      1 -1
      1 0x10
      1 '1+1'
      1 abc
    End

    It '形式不正を拒否し結果変数を変更しない'
      load_subject sx_arg_isep
      res=old
      When call sx_arg_isep res p "$1" "$2" ::: a b
      The status should equal 64
      The variable res should equal old
    End
  End

  It '空の間隔と上限は既定値として扱う'
    load_subject sx_arg_isep
    When call sx_arg_isep res p '' '' ::: a b c
    The status should be success
    The variable res should equal "'a' 'p' 'b' 'p' 'c'"
  End

  It '引数個数には安全範囲検証を適用しない'
    load_subject sx_arg_isep
    __sx_num_is_nat0_safe() { case "${1-}" in '') return 0;; *) return 1;; esac; }
    When call sx_arg_isep res p a b c
    The status should be success
    The variable res should equal "'a' 'p' 'b' 'p' 'c'"
  End

  It 'フラグには引き続き安全範囲検証を適用する'
    load_subject sx_arg_isep
    sx_test_setup sx_cfg_set NUM_RANGE=32
    res=old
    When call sx_arg_isep res p 9223372036854775808 '' 2147483648 ::: a b
    The status should equal 64
    The variable res should equal old
  End

  It '不正な数値設定はEX_CONFIGを返す'
    load_subject sx_arg_isep
    SX_CFG_NUM_RANGE=bogus
    When call sx_arg_isep res p ::: a b
    The status should equal 78
  End

  Context '8bit算術域の前後'
    Parameters:matrix
      126 127 128
      1 -1
      lit cb skip
    End

    It '個数+1の挿入回数とスキップ数を桁溢れさせない'
      load_subject __sx_arg_isep
      size="$1" interval="$2" mode="$3" idx=0 expected="'p'"
      set --
      while [ "$idx" -lt "$size" ]; do
        idx=$((idx + 1))
        set -- "$@" a
        expected="$expected 'a' 'p'"
      done
      expected_count=$((size + 1))
      sx_test_setup __sx_cfg_set NUM_RANGE=8
      case "$size" in
        126) __sx_num_add1_nat0() { return 64; }; __sx_num_sub1_nat0() { return 64; };;
        *) __sx_num_add1_arith() { return 64; }; __sx_num_sub1_arith() { return 64; };;
      esac
      last_slot=0 last_count=0 last_skip=0
      cb() {
        last_slot="$2" last_count="$3" last_skip="$4"
        case "$mode" in skip) unset "$1";; *) sx_test_setup sx_var_set "${1}=p";; esac
      }
      case "$mode" in
        lit) sep=p flag=6;;
        cb) sep=cb flag=7;;
        skip) sep=cb flag=7; sx_test_setup __sx_arg_quote expected "$@";;
      esac
      When call __sx_arg_isep res "$sep" "$interval" '' "$flag" ::: "$@"
      The status should be success
      The variable res should equal "$expected"
      case "$mode" in cb | skip)
        case "$interval" in 1) expected_slot="$size";; *) expected_slot=0;; esac
        The variable last_slot should equal "$expected_slot"
        The variable last_count should equal "$expected_count"
      esac
      case "$mode" in skip)
        The variable last_skip should equal "$size"
      esac
    End
  End

  Context '多倍長経路の複数要素ごとの挿入'
    Parameters:matrix
      2 -2 127 -127 128 -128 129 -129
      0 1
    End

    It '間隔の絶対値・除算・次の境界を正しく扱う'
      load_subject __sx_arg_isep
      interval="$1" mode="$2" idx=0 expected='' sep=p flag=6
      case "$mode" in 1) sep=cb flag=7;; esac
      cb() { sx_test_setup sx_var_set "${1}=p"; }
      set --
      # 128要素の境界を独立に列挙し、方向に対する距離が間隔の倍数なら挿入する。
      while [ "$idx" -le 128 ]; do
        case "$interval" in
          -*) distance=$((128 - idx));;
          *) distance="$idx";;
        esac
        if [ "$((distance % ${interval#-}))" -eq 0 ]; then
          expected="${expected}${expected:+ }'p'"
        fi
        [ "$idx" -lt 128 ] || break
        set -- "$@" a
        expected="${expected}${expected:+ }'a'"
        idx=$((idx + 1))
      done
      # 除算には公開設定の32bitを使い、isep の数値経路だけを切り替える。
      sx_test_setup sx_cfg_set NUM_RANGE=32
      select_isep_path nat0
      When call __sx_arg_isep res "$sep" "$interval" '' "$flag" ::: "$@"
      The status should be success
      The variable res should equal "$expected"
    End
  End
End
