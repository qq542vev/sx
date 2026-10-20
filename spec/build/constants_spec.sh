#!/bin/sh
# shellcheck disable=SC2016 # m4 に渡すコードや引用対象はシェルで展開しない。
# shellcheck disable=SC2288 # Parameters 内の引用符を含む入力値はコマンド名ではない。

eval "$(shellspec - -c) exit 1"

Describe 'm4 による定数値の生成と引用'
  expand_constant() {
    constant_script=$(
      printf '\nconstant_value=%s\n' "$1" | m4 -- m4/common.m4 -
    ) || return
    eval "${constant_script}" || return
    unset constant_script
  }

  quote_source() {
    printf '%s\n' "$1" | m4 -- m4/common.m4 -
  }

  const_source() {
    printf 'define([|M_TEST_VALUE|], [|[|%s|]|])dnl\nM_CONST([|TEST_VALUE|])\n' "$1" |
      m4 -- m4/common.m4 -
  }

  load_declaration() {
    constant_script=$(quote_source "$1") || return
    eval "${constant_script}" || return
    unset constant_script
  }

  compare_compacted_constants() {
    original_values=$(
      original_constants=$(m4 -- m4/resolve.m4) || exit
      eval "${original_constants}" || exit
      readonly -p
    ) || return
    compacted_values=$(
      original_constants=$(m4 -- m4/resolve.m4) || exit
      compacted_constants=$(
        printf '%s\n' "${original_constants}" | LC_ALL=C awk -f tools/compact.awk
      ) || exit
      eval "${compacted_constants}" || exit
      readonly -p
    ) || return
    [ "${original_values}" = "${compacted_values}" ]
  }

  It '空文字列を引用できること'
    When call expand_constant 'M_SH_QUOTE([||])'
    The status should be success
    The variable constant_value should equal ''
  End

  It '空文字列を通常の単一引用符で出力すること'
    When run quote_source 'M_SH_QUOTE([||])'
    The status should be success
    The output should equal "''"
  End

  It '連続する単一引用符をまとめて引用の外でエスケープすること'
    When run quote_source "M_SH_QUOTE([|あ''う|])"
    The status should be success
    The output should equal "'あ'\\'\\''う'"
  End

  Context '先頭・末尾・単一引用符だけの入力'
    Parameters
      "'あ"
      "あ'"
      "'"
      "''"
      "'''"
      "'''あ''う'''"
      "あ'\\'う"
    End

    It '引用符とバックスラッシュを元の値に復元できること'
      When call expand_constant "M_SH_QUOTE([|${1}|])"
      The status should be success
      The variable constant_value should equal "${1}"
    End
  End

  It '引用符・バックスラッシュ・シェル構文を値として保持すること'
    input="  a'b\c \$HOME \$(exit 99) \`exit 99\` #;*?()[],  "
    When call expand_constant "M_SH_QUOTE([|${input}|])"
    The status should be success
    The variable constant_value should equal "${input}"
  End

  It '値に含まれる m4 のマクロ名を再展開しないこと'
    input='define M_SH_QUOTE __M_SH_QUOTE_APOS __M_SH_QUOTE_JOIN M_STR_DIGIT M_EX_USAGE'
    When call expand_constant "M_SH_QUOTE([|${input}|])"
    The status should be success
    The variable constant_value should equal "${input}"
  End

  It '改行と末尾の空白・改行を保持すること'
    input='先頭

  # 値の一部
末尾'
    input="${input}  "
    input="${input}

"
    When call expand_constant "M_SH_QUOTE([|${input}|])"
    The status should be success
    The variable constant_value should equal "${input}"
  End

  It 'エスケープに見える文字列をそのまま保持すること'
    input='\n\001\123\cA'
    When call expand_constant "M_SH_QUOTE([|${input}|])"
    The status should be success
    The variable constant_value should equal "${input}"
  End

  It 'すべての対象制御文字を実際の文字のまま保持すること'
    expected=$(printf '\001\002\003\004\005\006\007\010\011\012\013\014\015\016\017\020\021\022\023\024\025\026\027\030\031\032\033\034\035\036\037\177')
    When call expand_constant 'M_SH_QUOTE(M_STR_CNTRL)'
    The status should be success
    The variable constant_value should equal "${expected}"
  End

  It 'LF をエスケープ表記に変換せず出力すること'
    expected="'
'"
    When run quote_source 'M_SH_QUOTE(M_STR_LF)'
    The status should be success
    The output should equal "${expected}"
  End

  It '合成された ASCII マクロを一つの引数として引用できること'
    expected=$(printf '\001\002\003\004\005\006\007\010\011\012\013\014\015\016\017\020\021\022\023\024\025\026\027\030\031\032\033\034\035\036\037\177%s' ' !"#$%&'\''()*+,-./:;<=>?@[\]^_`{|}~0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz')
    When call expand_constant 'M_SH_QUOTE(M_STR_ASCII)'
    The status should be success
    The variable constant_value should equal "${expected}"
  End

  It '生成された桁数別定数もマクロから参照できること'
    When call expand_constant 'M_SH_QUOTE(M_NUM_ZR_37)'
    The status should be success
    The variable constant_value should equal '0000000000000000000000000000000000000'
  End

  It '整数定数を算術評価せずに置換できること'
    When call expand_constant 'M_NUM_I128_MIN'
    The status should be success
    The variable constant_value should equal '-170141183460469231731687303715884105728'
  End

  It '複数行の定数宣言も圧縮前後で値が保持されること'
    When call compare_compacted_constants
    The status should be success
  End

  It 'Portable Filename Character Set の値は引用せず宣言すること'
    input='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789._-'
    When run const_source "${input}"
    The status should be success
    The output should equal "readonly SX_TEST_VALUE=${input}"
  End

  Context '空文字列と引用を必要とする定数値'
    Parameters
      # shellcheck disable=SC2286 # Parameters の空文字列は入力データであり、コマンド名ではない。
      '' "readonly SX_TEST_VALUE=''"
      'a/b' "readonly SX_TEST_VALUE='a/b'"
      'a:b' "readonly SX_TEST_VALUE='a:b'"
      'a+b' "readonly SX_TEST_VALUE='a+b'"
      'a@b' "readonly SX_TEST_VALUE='a@b'"
      'a=b' "readonly SX_TEST_VALUE='a=b'"
      'a%b' "readonly SX_TEST_VALUE='a%b'"
      'a,b' "readonly SX_TEST_VALUE='a,b'"
      'a(b' "readonly SX_TEST_VALUE='a(b'"
      'a b' "readonly SX_TEST_VALUE='a b'"
      '日本語' "readonly SX_TEST_VALUE='日本語'"
      "a''b" "readonly SX_TEST_VALUE='a'\\'\\''b'"
    End

    It '値を単一引用符方式で引用して宣言すること'
      When run const_source "${1}"
      The status should be success
      The output should equal "${2}"
    End
  End

  It '値に含まれるマクロ名を出力時に再展開しないこと'
    When run const_source 'M_SH_QUOTE'
    The status should be success
    The output should equal 'readonly SX_TEST_VALUE=M_SH_QUOTE'
  End

  It '数値定数も算術評価せず宣言すること'
    When run quote_source 'M_CONST([|NUM_I128_MIN|])'
    The status should be success
    The output should equal 'readonly SX_NUM_I128_MIN=-170141183460469231731687303715884105728'
  End

  It '句読点の集合をカンマ・括弧を含めて復元できること'
    expected='!"#$%&'\''()*+,-./:;<=>?@[\]^_`{|}~'
    When call load_declaration 'M_CONST([|STR_PUNCT|])'
    The status should be success
    The variable SX_STR_PUNCT should equal "${expected}"
  End
End
