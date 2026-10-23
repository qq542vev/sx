#!/bin/sh
# shellcheck disable=SC2016 # CMD内の変数は準備用シェルで展開する。
# Parameters 内の空文字列・負数・末尾空白はコマンドではなくテストデータ。
# shellcheck disable=SC2215,SC2286,SC2288

eval "$(shellspec - -c) exit 1"

Describe 'sx_str_split 多倍長対応'
  # Exampleごとに対象だけを読み込む。IncludeはExampleの外で宣言する。
  load_subject() {
    case "$1" in
      sx_str_split)
        Include ./spec/support/library.sh sx_str_split
        ;;
      __sx_str_split)
        Include ./spec/support/library.sh __sx_str_split
        ;;
      *) return 64;;
    esac
  }

  Include ./spec/support/run.sh

  Context '算術域を超える回数'
    Parameters
      '0' 'abc' '' '999999999999999999999999999999' '0' ''\'''\'' '\''a'\'' '\''b'\'' '\''c'\'' '\'''\'''
      '0' 'abc' '' '999999999999999999999999999999' '2' ''\'''\'' '\'''\'' '\''a'\'' '\'''\'' '\''b'\'' '\'''\'' '\''c'\'' '\'''\'' '\'''\'''
      '0' 'a:b:c' ':' '999999999999999999999999999999' '0' ''\''a'\'' '\''b'\'' '\''c'\'''
      '0' 'a:b:c' ':' '999999999999999999999999999999' '2' ''\''a'\'' '\'':'\'' '\''b'\'' '\'':'\'' '\''c'\'''
      '0' 'a1b2c' '[0-9]' '999999999999999999999999999999' '1' ''\''a'\'' '\''b'\'' '\''c'\'''
      '0' 'a1b2c' '[0-9]' '999999999999999999999999999999' '3' ''\''a'\'' '\''1'\'' '\''b'\'' '\''2'\'' '\''c'\'''
      '0' 'abc' '' '+999999999999999999999999999999' '0' ''\'''\'' '\''a'\'' '\''b'\'' '\''c'\'' '\'''\'''
      '0' 'abc' '' '+999999999999999999999999999999' '2' ''\'''\'' '\'''\'' '\''a'\'' '\'''\'' '\''b'\'' '\'''\'' '\''c'\'' '\'''\'' '\'''\'''
      '0' 'a:b:c' ':' '+999999999999999999999999999999' '0' ''\''a'\'' '\''b'\'' '\''c'\'''
      '0' 'a:b:c' ':' '+999999999999999999999999999999' '2' ''\''a'\'' '\'':'\'' '\''b'\'' '\'':'\'' '\''c'\'''
      '0' 'a1b2c' '[0-9]' '+999999999999999999999999999999' '1' ''\''a'\'' '\''b'\'' '\''c'\'''
      '0' 'a1b2c' '[0-9]' '+999999999999999999999999999999' '3' ''\''a'\'' '\''1'\'' '\''b'\'' '\''2'\'' '\''c'\'''
      '0' 'abc' '' '-999999999999999999999999999999' '0' ''\'''\'' '\''a'\'' '\''b'\'' '\''c'\'' '\'''\'''
      '0' 'abc' '' '-999999999999999999999999999999' '2' ''\'''\'' '\'''\'' '\''a'\'' '\'''\'' '\''b'\'' '\'''\'' '\''c'\'' '\'''\'' '\'''\'''
      '0' 'a:b:c' ':' '-999999999999999999999999999999' '0' ''\''a'\'' '\''b'\'' '\''c'\'''
      '0' 'a:b:c' ':' '-999999999999999999999999999999' '2' ''\''a'\'' '\'':'\'' '\''b'\'' '\'':'\'' '\''c'\'''
      '0' 'a1b2c' '[0-9]' '-999999999999999999999999999999' '1' ''\''a'\'' '\''b'\'' '\''c'\'''
      '0' 'a1b2c' '[0-9]' '-999999999999999999999999999999' '3' ''\''a'\'' '\''1'\'' '\''b'\'' '\''2'\'' '\''c'\'''
      '0' 'abc' '' '-9223372036854775808' '0' ''\'''\'' '\''a'\'' '\''b'\'' '\''c'\'' '\'''\'''
      '0' 'abc' '' '-9223372036854775808' '2' ''\'''\'' '\'''\'' '\''a'\'' '\'''\'' '\''b'\'' '\'''\'' '\''c'\'' '\'''\'' '\'''\'''
      '0' 'a:b:c' ':' '-9223372036854775808' '0' ''\''a'\'' '\''b'\'' '\''c'\'''
      '0' 'a:b:c' ':' '-9223372036854775808' '2' ''\''a'\'' '\'':'\'' '\''b'\'' '\'':'\'' '\''c'\'''
      '0' 'a1b2c' '[0-9]' '-9223372036854775808' '1' ''\''a'\'' '\''b'\'' '\''c'\'''
      '0' 'a1b2c' '[0-9]' '-9223372036854775808' '3' ''\''a'\'' '\''1'\'' '\''b'\'' '\''2'\'' '\''c'\'''
      '0' 'abc' '' '9223372036854775807' '0' ''\'''\'' '\''a'\'' '\''b'\'' '\''c'\'' '\'''\'''
      '0' 'abc' '' '9223372036854775807' '2' ''\'''\'' '\'''\'' '\''a'\'' '\'''\'' '\''b'\'' '\'''\'' '\''c'\'' '\'''\'' '\'''\'''
      '0' 'a:b:c' ':' '9223372036854775807' '0' ''\''a'\'' '\''b'\'' '\''c'\'''
      '0' 'a:b:c' ':' '9223372036854775807' '2' ''\''a'\'' '\'':'\'' '\''b'\'' '\'':'\'' '\''c'\'''
      '0' 'a1b2c' '[0-9]' '9223372036854775807' '1' ''\''a'\'' '\''b'\'' '\''c'\'''
      '0' 'a1b2c' '[0-9]' '9223372036854775807' '3' ''\''a'\'' '\''1'\'' '\''b'\'' '\''2'\'' '\''c'\'''
      '1' 'abc' '' '999999999999999999999999999999' '0' ''\'''\'' '\''a'\'' '\''b'\'' '\''c'\'' '\'''\'''
      '1' 'abc' '' '999999999999999999999999999999' '2' ''\'''\'' '\'''\'' '\''a'\'' '\'''\'' '\''b'\'' '\'''\'' '\''c'\'' '\'''\'' '\'''\'''
      '1' 'a:b:c' ':' '999999999999999999999999999999' '0' ''\''a'\'' '\''b'\'' '\''c'\'''
      '1' 'a:b:c' ':' '999999999999999999999999999999' '2' ''\''a'\'' '\'':'\'' '\''b'\'' '\'':'\'' '\''c'\'''
      '1' 'a1b2c' '[0-9]' '999999999999999999999999999999' '1' ''\''a'\'' '\''b'\'' '\''c'\'''
      '1' 'a1b2c' '[0-9]' '999999999999999999999999999999' '3' ''\''a'\'' '\''1'\'' '\''b'\'' '\''2'\'' '\''c'\'''
      '1' 'abc' '' '+999999999999999999999999999999' '0' ''\'''\'' '\''a'\'' '\''b'\'' '\''c'\'' '\'''\'''
      '1' 'abc' '' '+999999999999999999999999999999' '2' ''\'''\'' '\'''\'' '\''a'\'' '\'''\'' '\''b'\'' '\'''\'' '\''c'\'' '\'''\'' '\'''\'''
      '1' 'a:b:c' ':' '+999999999999999999999999999999' '0' ''\''a'\'' '\''b'\'' '\''c'\'''
      '1' 'a:b:c' ':' '+999999999999999999999999999999' '2' ''\''a'\'' '\'':'\'' '\''b'\'' '\'':'\'' '\''c'\'''
      '1' 'a1b2c' '[0-9]' '+999999999999999999999999999999' '1' ''\''a'\'' '\''b'\'' '\''c'\'''
      '1' 'a1b2c' '[0-9]' '+999999999999999999999999999999' '3' ''\''a'\'' '\''1'\'' '\''b'\'' '\''2'\'' '\''c'\'''
      '1' 'abc' '' '-999999999999999999999999999999' '0' ''\'''\'' '\''a'\'' '\''b'\'' '\''c'\'' '\'''\'''
      '1' 'abc' '' '-999999999999999999999999999999' '2' ''\'''\'' '\'''\'' '\''a'\'' '\'''\'' '\''b'\'' '\'''\'' '\''c'\'' '\'''\'' '\'''\'''
      '1' 'a:b:c' ':' '-999999999999999999999999999999' '0' ''\''a'\'' '\''b'\'' '\''c'\'''
      '1' 'a:b:c' ':' '-999999999999999999999999999999' '2' ''\''a'\'' '\'':'\'' '\''b'\'' '\'':'\'' '\''c'\'''
      '1' 'a1b2c' '[0-9]' '-999999999999999999999999999999' '1' ''\''a'\'' '\''b'\'' '\''c'\'''
      '1' 'a1b2c' '[0-9]' '-999999999999999999999999999999' '3' ''\''a'\'' '\''1'\'' '\''b'\'' '\''2'\'' '\''c'\'''
      '1' 'abc' '' '-9223372036854775808' '0' ''\'''\'' '\''a'\'' '\''b'\'' '\''c'\'' '\'''\'''
      '1' 'abc' '' '-9223372036854775808' '2' ''\'''\'' '\'''\'' '\''a'\'' '\'''\'' '\''b'\'' '\'''\'' '\''c'\'' '\'''\'' '\'''\'''
      '1' 'a:b:c' ':' '-9223372036854775808' '0' ''\''a'\'' '\''b'\'' '\''c'\'''
      '1' 'a:b:c' ':' '-9223372036854775808' '2' ''\''a'\'' '\'':'\'' '\''b'\'' '\'':'\'' '\''c'\'''
      '1' 'a1b2c' '[0-9]' '-9223372036854775808' '1' ''\''a'\'' '\''b'\'' '\''c'\'''
      '1' 'a1b2c' '[0-9]' '-9223372036854775808' '3' ''\''a'\'' '\''1'\'' '\''b'\'' '\''2'\'' '\''c'\'''
      '1' 'abc' '' '9223372036854775807' '0' ''\'''\'' '\''a'\'' '\''b'\'' '\''c'\'' '\'''\'''
      '1' 'abc' '' '9223372036854775807' '2' ''\'''\'' '\'''\'' '\''a'\'' '\'''\'' '\''b'\'' '\'''\'' '\''c'\'' '\'''\'' '\'''\'''
      '1' 'a:b:c' ':' '9223372036854775807' '0' ''\''a'\'' '\''b'\'' '\''c'\'''
      '1' 'a:b:c' ':' '9223372036854775807' '2' ''\''a'\'' '\'':'\'' '\''b'\'' '\'':'\'' '\''c'\'''
      '1' 'a1b2c' '[0-9]' '9223372036854775807' '1' ''\''a'\'' '\''b'\'' '\''c'\'''
      '1' 'a1b2c' '[0-9]' '9223372036854775807' '3' ''\''a'\'' '\''1'\'' '\''b'\'' '\''2'\'' '\''c'\'''
    End

    It '検査の有無・方向・区切り・INCによらず任意桁の回数を受け付けること'
      load_subject sx_str_split
      sxtest_run SX_CFG_SKIP_CHK -- 'sx_cfg_set "$@"' "SKIP_CHK=$1"
      When call sx_str_split res "$2" "$3" "$4" "$5"
      The status should be success
      The variable res should equal "$6"
    End
  End

  Context '空区切りの境界モデル'
    split_both() {
      sx_str_split res "$1" '' "$2" || return
      sx_str_split inc "$1" '' "$2" "$SX_STR_SPLIT_INC"
    }

    Parameters
      '' 0 "''" "''"
      '' 1 "'' ''" "'' '' ''"
      '' -1 "'' ''" "'' '' ''"
      '' '' "'' ''" "'' '' ''"
      A 0 "'A'" "'A'"
      A 1 "'' 'A'" "'' '' 'A'"
      A -1 "'A' ''" "'A' '' ''"
      A 2 "'' 'A' ''" "'' '' 'A' '' ''"
      A -2 "'' 'A' ''" "'' '' 'A' '' ''"
      A 3 "'' 'A' ''" "'' '' 'A' '' ''"
      A -3 "'' 'A' ''" "'' '' 'A' '' ''"
      abcde 0 "'abcde'" "'abcde'"
      abcde +0 "'abcde'" "'abcde'"
      abcde -0 "'abcde'" "'abcde'"
      abcde +2 "'' 'a' 'bcde'" "'' '' 'a' '' 'bcde'"
      abcde 1 "'' 'abcde'" "'' '' 'abcde'"
      abcde 2 "'' 'a' 'bcde'" "'' '' 'a' '' 'bcde'"
      abcde 3 "'' 'a' 'b' 'cde'" "'' '' 'a' '' 'b' '' 'cde'"
      abcde 5 "'' 'a' 'b' 'c' 'd' 'e'" "'' '' 'a' '' 'b' '' 'c' '' 'd' '' 'e'"
      abcde 6 "'' 'a' 'b' 'c' 'd' 'e' ''" "'' '' 'a' '' 'b' '' 'c' '' 'd' '' 'e' '' ''"
      abcde 7 "'' 'a' 'b' 'c' 'd' 'e' ''" "'' '' 'a' '' 'b' '' 'c' '' 'd' '' 'e' '' ''"
      abcde -1 "'abcde' ''" "'abcde' '' ''"
      abcde -2 "'abcd' 'e' ''" "'abcd' '' 'e' '' ''"
      abcde -3 "'abc' 'd' 'e' ''" "'abc' '' 'd' '' 'e' '' ''"
      abcde -5 "'a' 'b' 'c' 'd' 'e' ''" "'a' '' 'b' '' 'c' '' 'd' '' 'e' '' ''"
      abcde -6 "'' 'a' 'b' 'c' 'd' 'e' ''" "'' '' 'a' '' 'b' '' 'c' '' 'd' '' 'e' '' ''"
      abcde -7 "'' 'a' 'b' 'c' 'd' 'e' ''" "'' '' 'a' '' 'b' '' 'c' '' 'd' '' 'e' '' ''"
    End

    It '両端・文字間の境界を回数に数えINCの要素は回数に含めないこと'
      load_subject sx_str_split
      # 空区切りは中間リストを構築する関数に依存しない。
      __sx_str_chunk() { return 64; }
      __sx_arg_isep() { return 64; }
      When call split_both "$1" "$2"
      The status should be success
      The variable res should equal "$3"
      The variable inc should equal "$4"
    End
  End

  Context '回数の空指定'
    Parameters
      'a:b:c' ':' 0 "'a' 'b' 'c'"
      'a:b:c' ':' 2 "'a' ':' 'b' ':' 'c'"
      a1b2c '[0-9]' 3 "'a' '1' 'b' '2' 'c'"
      abc '**' 3 "'' '' 'a' '' 'b' '' 'c' '' ''"
      '' '**' 3 "'' '' ''"
    End

    It '空の回数は前方から無制限として扱うこと'
      load_subject sx_str_split
      When call sx_str_split res "$1" "$2" '' "$3"
      The status should be success
      The variable res should equal "$4"
    End
  End

  Context '不正な回数の拒否'
    Parameters
      00
      01
      -01
      +01
      010
      -010
      0x2
      -0x2
      1.0
      1e2
      '1+1'
      ' 1'
      '1 '
      +
      -
      invalid
    End

    It '形式不正を64で拒否し結果を変更しないこと'
      load_subject sx_str_split
      res=original
      When call sx_str_split res abc '' "$1"
      The status should equal 64
      The variable res should equal original
    End
  End

  Context 'フラグの互換性'
    Parameters
      -1
      0x3
      03
    End

    It 'フラグは従来の符号付き・8進・16進表記を維持すること'
      load_subject sx_str_split
      When call sx_str_split res a1b '[0-9]' 1 "$1"
      The status should be success
      The variable res should equal "'a' '1' 'b'"
    End
  End

  Context '不正なフラグの拒否'
    Parameters
      ''
      999999999999999999999999999999
      invalid
    End

    It 'フラグには引き続き算術域内の値を要求すること'
      load_subject sx_str_split
      res=original
      When call sx_str_split res abc '' '' "$1"
      The status should equal 64
      The variable res should equal original
    End
  End

  It '文字列長を安全範囲の検査で拒否しないこと'
    load_subject sx_str_split
    __sx_num_is_nat0_safe() { return 1; }
    When call sx_str_split res abc
    The status should be success
    The variable res should equal "'' 'a' 'b' 'c' ''"
  End

  Context '多倍長の数値経路'
    Parameters
      abc '' 999999999999999999999999 0 "'' 'a' 'b' 'c' ''"
      abc '' -999999999999999999999999 2 "'' '' 'a' '' 'b' '' 'c' '' ''"
      abcde '' 3 2 "'' '' 'a' '' 'b' '' 'cde'"
      abcde '' -3 0 "'abc' 'd' 'e' ''"
      'a:b:c' ':' 999999999999999999999999 2 "'a' ':' 'b' ':' 'c'"
      'a:b:c' ':' -999999999999999999999999 0 "'a' 'b' 'c'"
      a1b2c '[0-9]' 2 3 "'a' '1' 'b' '2' 'c'"
      a1b2c '[0-9]' -2 3 "'a' '1' 'b' '2' 'c'"
    End

    It '短い入力で多倍長経路を強制しても同じ結果になること'
      load_subject __sx_str_split
      native_calls=0
      __sx_num_is_int_fit_dec() { return 1; }
      # shellcheck disable=SC2329
      __sx_num_sub1_arith() { native_calls=$((native_calls + 1)); return 64; }
      When call __sx_str_split res "$1" "$2" "$3" "$4"
      The status should be success
      The variable res should equal "$5"
      The variable native_calls should equal 0
    End
  End

  Context '空区切りの減算省略'
    Parameters
      abc '' 0 "'' 'a' 'b' 'c' ''"
      abc '' 2 "'' '' 'a' '' 'b' '' 'c' '' ''"
      abc 4 0 "'' 'a' 'b' 'c' ''"
      abc 4 2 "'' '' 'a' '' 'b' '' 'c' '' ''"
      abc 999999999999999999999999 0 "'' 'a' 'b' 'c' ''"
      abc 999999999999999999999999 2 "'' '' 'a' '' 'b' '' 'c' '' ''"
      abc -1 0 "'abc' ''"
      abc -1 2 "'abc' '' ''"
      abc -3 0 "'a' 'b' 'c' ''"
      abc -3 2 "'a' '' 'b' '' 'c' '' ''"
      abc -999999999999999999999999 2 "'' '' 'a' '' 'b' '' 'c' '' ''"
      '' 1 0 "'' ''"
      '' 1 2 "'' '' ''"
    End

    It '前方の全境界分割では減算せず、後方では先頭準備の一回だけ減算すること'
      load_subject __sx_str_split
      counter_calls=0
      case "$2" in
        -*) expected_calls=1;;
        *) expected_calls=0;;
      esac
      # shellcheck disable=SC2329
      __sx_num_sub1_arith() {
        counter_calls=$((counter_calls + 1))
        __sx_num_sub_nat0 "$1" "$2" 1
      }
      # shellcheck disable=SC2329
      __sx_num_sub1_nat0() {
        counter_calls=$((counter_calls + 1))
        __sx_num_sub_nat0 "$1" "$2" 1
      }
      When call __sx_str_split res "$1" '' "$2" "$3"
      The status should be success
      The variable res should equal "$4"
      The variable counter_calls should equal "$expected_calls"
    End
  End

  Context '8bit範囲の空区切りの有限上限'
    Parameters
      126 0 126 0
      127 0 127 0
      128 0 0 128
      126 2 126 0
      127 2 127 0
      128 2 0 128
    End

    It '文字数と等しい上限では文末を切らず、最大値までは通常の算術を使うこと'
      load_subject __sx_str_split
      sxtest_run str -- 'sx_str_rep "$@"' str A "$1"
      case "$2" in
        0)
          sxtest_run expected -- 'sx_str_rep "$@"' expected "'A' " "$1"
          expected="'' ${expected% }"
          ;;
        *)
          count="$1"
          count=$((count - 1))
          sxtest_run expected -- 'sx_str_rep "$@"' expected "'A' '' " "$count"
          expected="'' '' $expected'A'"
          ;;
      esac
      sxtest_run SX_CFG_NUM_RANGE SX_SYS_NUM_WLEN SX_SYS_NUM_QM SX_SYS_NUM_ZR -- '__sx_cfg_set "$@"' NUM_RANGE=8
      native_calls=0 multiprecision_calls=0
      # shellcheck disable=SC2329
      __sx_num_sub1_arith() {
        native_calls=$((native_calls + 1))
        __sx_num_sub_nat0 "$1" "$2" 1
      }
      # shellcheck disable=SC2329
      __sx_num_sub1_nat0() {
        multiprecision_calls=$((multiprecision_calls + 1))
        __sx_num_sub_nat0 "$1" "$2" 1
      }
      When call __sx_str_split res "$str" '' "$1" "$2"
      The status should be success
      The variable res should equal "$expected"
      The variable native_calls should equal "$3"
      The variable multiprecision_calls should equal "$4"
    End
  End

  Context '8bit範囲の文字数と境界数'
    Parameters
      126 0
      127 0
      128 0
      126 2
      127 2
      128 2
    End

    It '文字数+1が算術域を越えても全境界を分割すること'
      load_subject __sx_str_split
      str='' expected=''
      sxtest_run str -- 'sx_str_rep "$@"' str A "$1"
      case "$2" in
        0)
          sxtest_run expected -- 'sx_str_rep "$@"' expected "'A' " "$1"
          expected="'' $expected''"
          ;;
        *)
          sxtest_run expected -- 'sx_str_rep "$@"' expected "'A' '' " "$1"
          expected="'' '' $expected''"
          ;;
      esac
      sxtest_run SX_CFG_NUM_RANGE SX_SYS_NUM_WLEN SX_SYS_NUM_QM SX_SYS_NUM_ZR -- '__sx_cfg_set "$@"' NUM_RANGE=8
      native_calls=0
      case "$1" in 127 | 128)
        # shellcheck disable=SC2329
        __sx_num_sub1_arith() { native_calls=$((native_calls + 1)); return 64; }
      esac
      When call __sx_str_split res "$str" '' 999999999999999999999999 "$2"
      The status should be success
      The variable res should equal "$expected"
      The variable native_calls should equal 0
    End
  End

  Context '8bit範囲の非空区切りの分割回数'
    Parameters
      127 1
      128 1
      129 1
      127 -1
      128 -1
      129 -1
    End

    It '分割回数が最大値を越えても全要素を保持すること'
      load_subject __sx_str_split
      str='' expected=''
      sxtest_run str -- 'sx_str_rep "$@"' str 'A:' "$1"
      sxtest_run expected -- 'sx_str_rep "$@"' expected "'A' " "$1"
      expected="$expected''"
      sxtest_run SX_CFG_NUM_RANGE SX_SYS_NUM_WLEN SX_SYS_NUM_QM SX_SYS_NUM_ZR -- '__sx_cfg_set "$@"' NUM_RANGE=8
      native_calls=0
      __sx_num_sub1_arith() { native_calls=$((native_calls + 1)); return 64; }
      case "$2" in
        1) set -- 999999999999999999999999;;
        *) set -- -999999999999999999999999;;
      esac
      When call __sx_str_split res "$str" : "$1"
      The status should be success
      The variable res should equal "$expected"
      The variable native_calls should equal 0
    End
  End

  Context '後方分割のパターン生成'
    Parameters
      -999999999999999999999999 "'' 'a' 'b' 'c' 'd' 'e' ''"
      -6 "'' 'a' 'b' 'c' 'd' 'e' ''"
      -1 "'abcde' ''"
    End

    It '先頭または後続が空の場合にパターンを生成しないこと'
      load_subject sx_str_split
      # shellcheck disable=SC2329
      __sx_str_qm() { return 64; }
      When call sx_str_split res abcde '' "$1"
      The status should be success
      The variable res should equal "$2"
    End
  End

  Context '後方分割の短い側の選択'
    Parameters
      -2 "'abcd' 'e' ''"
      -5 "'a' 'b' 'c' 'd' 'e' ''"
    End

    It '先頭と後続の短い側だけで切り出しパターンを生成すること'
      load_subject sx_str_split
      pattern_length=''
      __sx_str_qm() {
        pattern_length="$2"
        eval "${1}=?"
      }
      When call sx_str_split res abcde '' "$1"
      The status should be success
      The variable res should equal "$2"
      The variable pattern_length should equal 1
    End
  End

  It '設定不正を78で拒否し結果を変更しないこと'
    load_subject sx_str_split
    res=original
    SX_CFG_NUM_RANGE=invalid
    When call sx_str_split res abc
    The status should equal 78
    The variable res should equal original
  End

  It '不正なバインド形式を64で拒否すること'
    load_subject sx_str_split
    When call sx_str_split 1invalid abc
    The status should equal 64
  End

  It '読み取り専用の結果変数を77で拒否すること'
    load_subject sx_str_split
    readonly readonly_split=original
    When call sx_str_split readonly_split abc
    The status should equal 77
    The variable readonly_split should equal original
  End
End
