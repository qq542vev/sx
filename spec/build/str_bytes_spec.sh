#!/bin/sh
# shellcheck disable=SC2016 # m4入力と生成コードの期待値はシェルで展開しない。
# shellcheck disable=SC3003 # POSIX.1-2024のドル単一引用符で期待値を記述する。
# shellcheck disable=SC2288 # Parametersの各行は入力データである。

eval "$(shellspec - -c) exit 1"

Describe '番号付き単一文字のマクロと定数宣言'
  byte_macro_source() {
    # LFが末尾改行として除去されないよう、値の前後に印を付ける。
    printf ':M_STR_B%s:\n' "$1" | m4 -- m4/common.m4 -
  }

  byte_const_source() {
    m4 -- m4/common.m4 "src/const/str/SX_STR_B$1.m4"
  }

  Context '7ビット側のマクロ値'
    Parameters
      01 $'\001'
      0A $'\012'
      20 $'\040'
      27 $'\047'
      28 $'\050'
      29 $'\051'
      2C $'\054'
      30 $'\060'
      41 $'\101'
      5B $'\133'
      5C $'\134'
      5D $'\135'
      60 $'\140'
      7C $'\174'
      7F $'\177'
    End

    It '引用に注意が必要な文字も実文字で展開すること'
      When run byte_macro_source "$1"
      The status should be success
      The output should equal ":$2:"
    End
  End

  Context '8ビット側のマクロ値'
    Parameters
      80 '\x80'
      9B '\x9B'
      FE '\xFE'
      FF '\xFF'
    End

    It '非ASCII文字を埋め込まずエスケープ列で展開すること'
      When run byte_macro_source "$1"
      The status should be success
      The output should equal ":$2:"
    End
  End

  It 'LFを実際の改行として通常の単一引用符で宣言すること'
    expected="readonly SX_STR_B0A='
'"
    When run byte_const_source 0A
    The status should be success
    The output should equal "$expected"
  End

  Context '7ビット側の通常の定数宣言'
    Parameters
      30 'readonly SX_STR_B30=0'
      41 'readonly SX_STR_B41=A'
      5B "readonly SX_STR_B5B='['"
      5C "readonly SX_STR_B5C='\'"
    End

    It '通常の引用規則でreadonlyを生成すること'
      When run byte_const_source "$1"
      The status should be success
      The output should equal "$2"
    End
  End

  Context '8ビット側の定数宣言'
    Parameters
      80 "readonly SX_STR_B80=\$'\x80'"
      FF "readonly SX_STR_BFF=\$'\xFF'"
    End

    It 'ドル単一引用符でreadonlyを生成すること'
      When run byte_const_source "$1"
      The status should be success
      The output should equal "$2"
    End
  End

  It 'NULのマクロは定義しないこと'
    When run byte_macro_source 00
    The status should be success
    The output should equal ':M_STR_B00:'
  End

  It 'NULの予約名は代入せず、未設定のreadonlyとして宣言すること'
    expected='unset -v SX_STR_B00
readonly SX_STR_B00'
    When run byte_const_source 00
    The status should be success
    The output should equal "$expected"
  End
End
