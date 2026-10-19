#!/bin/sh
# shellcheck disable=SC2016 # m4 に渡すコードや引用対象はシェルで展開しない。

eval "$(shellspec - -c) exit 1"

Describe 'm4 による定数値の生成と引用'
  expand_constant() {
    constant_script=$(
      printf '\nconstant_value=%s\n' "$1" | m4 -- sx.m4 -
    ) || return
    eval "${constant_script}" || return
    unset constant_script
  }

  It '空文字列を引用できること'
    When call expand_constant 'M_STR_QUOTE([||])'
    The status should be success
    The variable constant_value should equal ''
  End

  It '引用符・バックスラッシュ・シェル構文を値として保持すること'
    input="  a'b\c \$HOME \$(exit 99) \`exit 99\` #;*?()[],  "
    When call expand_constant "M_STR_QUOTE([|${input}|])"
    The status should be success
    The variable constant_value should equal "${input}"
  End

  It '値に含まれる m4 のマクロ名を再展開しないこと'
    input='define M_STR_QUOTE M_STR_DIGIT M_EX_USAGE'
    When call expand_constant "M_STR_QUOTE([|${input}|])"
    The status should be success
    The variable constant_value should equal "${input}"
  End

  It '改行と末尾の空白・改行を保持すること'
    input='先頭

  # 値の一部
末尾'
    input="${input}  "$'\n\n'
    When call expand_constant "M_STR_QUOTE([|${input}|])"
    The status should be success
    The variable constant_value should equal "${input}"
  End

  It 'エスケープに見える文字列をそのまま保持すること'
    input='\n\001\123\cA'
    When call expand_constant "M_STR_QUOTE([|${input}|])"
    The status should be success
    The variable constant_value should equal "${input}"
  End

  It '合成された ASCII マクロを一つの引数として引用できること'
    expected=$'\001\002\003\004\005\006\007\010\011\012\013\014\015\016\017\020\021\022\023\024\025\026\027\030\031\032\033\034\035\036\037\177 !"#$%&\'()*+,-./:;<=>?@[\\]^_`{|}~0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'
    When call expand_constant 'M_STR_QUOTE(M_STR_ASCII)'
    The status should be success
    The variable constant_value should equal "${expected}"
  End

  It '生成された桁数別定数もマクロから参照できること'
    When call expand_constant 'M_STR_QUOTE(M_NUM_ZR_37)'
    The status should be success
    The variable constant_value should equal '0000000000000000000000000000000000000'
  End

  It '整数定数を算術評価せずに置換できること'
    When call expand_constant 'M_NUM_I128_MIN'
    The status should be success
    The variable constant_value should equal '-170141183460469231731687303715884105728'
  End

  It '生成物の固定定数宣言が一回の readonly に結合されること'
    When run awk '/^readonly / { count++ } END { print count }' sx.sh
    The status should be success
    The output should equal 1
  End
End
