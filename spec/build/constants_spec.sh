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

  const_escaped_source() {
    printf 'define([|M_TEST_VALUE|], [|[|%s|]|])dnl\nM_CONST_ESC([|TEST_VALUE|])\n' "$1" |
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

  It 'C1領域のマクロ値をエスケープ列のまま保持すること'
    When run quote_source 'M_STR_C1'
    The status should be success
    The output should equal '\x80\x81\x82\x83\x84\x85\x86\x87\x88\x89\x8A\x8B\x8C\x8D\x8E\x8F\x90\x91\x92\x93\x94\x95\x96\x97\x98\x99\x9A\x9B\x9C\x9D\x9E\x9F'
  End

  It 'GR領域のマクロ値をエスケープ列のまま保持すること'
    When run quote_source 'M_STR_GR'
    The status should be success
    The output should equal '\xA0\xA1\xA2\xA3\xA4\xA5\xA6\xA7\xA8\xA9\xAA\xAB\xAC\xAD\xAE\xAF\xB0\xB1\xB2\xB3\xB4\xB5\xB6\xB7\xB8\xB9\xBA\xBB\xBC\xBD\xBE\xBF\xC0\xC1\xC2\xC3\xC4\xC5\xC6\xC7\xC8\xC9\xCA\xCB\xCC\xCD\xCE\xCF\xD0\xD1\xD2\xD3\xD4\xD5\xD6\xD7\xD8\xD9\xDA\xDB\xDC\xDD\xDE\xDF\xE0\xE1\xE2\xE3\xE4\xE5\xE6\xE7\xE8\xE9\xEA\xEB\xEC\xED\xEE\xEF\xF0\xF1\xF2\xF3\xF4\xF5\xF6\xF7\xF8\xF9\xFA\xFB\xFC\xFD\xFE\xFF'
  End

  It '整数定数を算術評価せずに置換できること'
    When call expand_constant 'M_NUM_I128_MIN'
    The status should be success
    The variable constant_value should equal '-170141183460469231731687303715884105728'
  End

  It '制御文字全体のマクロでC0・DELの実文字とC1のエスケープ列を連結すること'
    expected=$(printf '\001\002\003\004\005\006\007\010\011\012\013\014\015\016\017\020\021\022\023\024\025\026\027\030\031\032\033\034\035\036\037\177%s' '\x80\x81\x82\x83\x84\x85\x86\x87\x88\x89\x8A\x8B\x8C\x8D\x8E\x8F\x90\x91\x92\x93\x94\x95\x96\x97\x98\x99\x9A\x9B\x9C\x9D\x9E\x9F')
    When run quote_source 'M_STR_CONTROL'
    The status should be success
    The output should equal "${expected}"
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

  Context 'エスケープ列を保持する定数宣言'
    Parameters
      # shellcheck disable=SC2286 # 空文字列も入力データとして検査する。
      '' "readonly SX_TEST_VALUE=\$''"
      '\x80\xFE\xFF' "readonly SX_TEST_VALUE=\$'\x80\xFE\xFF'"
      '\x41\n\047\134' "readonly SX_TEST_VALUE=\$'\x41\n\047\134'"
      'M_EX_USAGE,$(exit 99)' "readonly SX_TEST_VALUE=\$'M_EX_USAGE,\$(exit 99)'"
    End

    It '値を再展開せずドル単一引用符で宣言すること'
      When run const_escaped_source "${1}"
      The status should be success
      The output should equal "${2}"
    End
  End

  It 'エスケープ列を実行時に復号し、シェル構文は値として保持すること'
    expected="A
'\M_EX_USAGE,\$(exit 99)"
    When call load_declaration 'define([|M_TEST_VALUE|], [|[|\x41\n\047\134M_EX_USAGE,$(exit 99)|]|])dnl
M_CONST_ESC([|TEST_VALUE|])'
    The status should be success
    The variable SX_TEST_VALUE should equal "${expected}"
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
