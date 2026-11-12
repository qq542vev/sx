#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe '共通マクロと定数の個別展開'
  expand_split_constants() {
    m4 -- m4/common.m4 "${@}"
  }

  compare_split_constants() {
    original_constants=$(
      original_script=$(m4 -- m4/resolve.m4) || exit
      eval "${original_script}" || exit
      readonly -p
    ) || return
    split_constants=$(
      split_script=$(expand_split_constants src/const.m4) || exit
      eval "${split_script}" || exit
      readonly -p
    ) || return
    [ "${original_constants}" = "${split_constants}" ]
  }

  It '共通ファイルだけでは実行時コードを出力しないこと'
    When run expand_split_constants
    The status should be success
    The output should equal ''
  End

  It '2進数字の定数を単独で出力すること'
    When run expand_split_constants src/const/str/SX_STR_BIN.m4
    The status should be success
    The output should equal 'readonly SX_STR_BIN=01'
  End

  It '合成定数だけを出力し、合成元の実行時定数を出力しないこと'
    When run expand_split_constants src/const/str/SX_STR_ALNUM.m4
    The status should be success
    The output should equal 'readonly SX_STR_ALNUM=0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'
  End

  It 'C0集合を実文字列として単独で宣言すること'
    expected=$(printf '\001\002\003\004\005\006\007\010\011\012\013\014\015\016\017\020\021\022\023\024\025\026\027\030\031\032\033\034\035\036\037')
    When run expand_split_constants src/const/str/SX_STR_C0.m4
    The status should be success
    The output should equal "readonly SX_STR_C0='${expected}'"
  End

  Context 'C1定数の単独展開'
    Parameters
      BPH '\x82'
      CSI '\x9B'
      APC '\x9F'
      C1 '\x80\x81\x82\x83\x84\x85\x86\x87\x88\x89\x8A\x8B\x8C\x8D\x8E\x8F\x90\x91\x92\x93\x94\x95\x96\x97\x98\x99\x9A\x9B\x9C\x9D\x9E\x9F'
    End

    It '生の高位バイトを埋め込まずドル単一引用符で一つだけ宣言すること'
      When run expand_split_constants "src/const/str/SX_STR_${1}.m4"
      The status should be success
      The output should equal "readonly SX_STR_${1}=\$'${2}'"
    End
  End

  It 'GR集合を生の高位バイトを埋め込まず一つだけ宣言すること'
    expected="readonly SX_STR_GR=\$'\xA0\xA1\xA2\xA3\xA4\xA5\xA6\xA7\xA8\xA9\xAA\xAB\xAC\xAD\xAE\xAF\xB0\xB1\xB2\xB3\xB4\xB5\xB6\xB7\xB8\xB9\xBA\xBB\xBC\xBD\xBE\xBF\xC0\xC1\xC2\xC3\xC4\xC5\xC6\xC7\xC8\xC9\xCA\xCB\xCC\xCD\xCE\xCF\xD0\xD1\xD2\xD3\xD4\xD5\xD6\xD7\xD8\xD9\xDA\xDB\xDC\xDD\xDE\xDF\xE0\xE1\xE2\xE3\xE4\xE5\xE6\xE7\xE8\xE9\xEA\xEB\xEC\xED\xEE\xEF\xF0\xF1\xF2\xF3\xF4\xF5\xF6\xF7\xF8\xF9\xFA\xFB\xFC\xFD\xFE\xFF'"
    When run expand_split_constants src/const/str/SX_STR_GR.m4
    The status should be success
    The output should equal "${expected}"
  End

  It '図形集合をドル単一引用符で一つだけ宣言すること'
    ascii='!"#$%&\'\''()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~'
    gr='\xA0\xA1\xA2\xA3\xA4\xA5\xA6\xA7\xA8\xA9\xAA\xAB\xAC\xAD\xAE\xAF\xB0\xB1\xB2\xB3\xB4\xB5\xB6\xB7\xB8\xB9\xBA\xBB\xBC\xBD\xBE\xBF\xC0\xC1\xC2\xC3\xC4\xC5\xC6\xC7\xC8\xC9\xCA\xCB\xCC\xCD\xCE\xCF\xD0\xD1\xD2\xD3\xD4\xD5\xD6\xD7\xD8\xD9\xDA\xDB\xDC\xDD\xDE\xDF\xE0\xE1\xE2\xE3\xE4\xE5\xE6\xE7\xE8\xE9\xEA\xEB\xEC\xED\xEE\xEF\xF0\xF1\xF2\xF3\xF4\xF5\xF6\xF7\xF8\xF9\xFA\xFB\xFC\xFD\xFE\xFF'
    When run expand_split_constants src/const/str/SX_STR_GRAPHIC.m4
    The status should be success
    The output should equal "readonly SX_STR_GRAPHIC=\$'${ascii}${gr}'"
  End

  It '印字集合をドル単一引用符で一つだけ宣言すること'
    ascii=' !"#$%&\'\''()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~'
    gr='\xA0\xA1\xA2\xA3\xA4\xA5\xA6\xA7\xA8\xA9\xAA\xAB\xAC\xAD\xAE\xAF\xB0\xB1\xB2\xB3\xB4\xB5\xB6\xB7\xB8\xB9\xBA\xBB\xBC\xBD\xBE\xBF\xC0\xC1\xC2\xC3\xC4\xC5\xC6\xC7\xC8\xC9\xCA\xCB\xCC\xCD\xCE\xCF\xD0\xD1\xD2\xD3\xD4\xD5\xD6\xD7\xD8\xD9\xDA\xDB\xDC\xDD\xDE\xDF\xE0\xE1\xE2\xE3\xE4\xE5\xE6\xE7\xE8\xE9\xEA\xEB\xEC\xED\xEE\xEF\xF0\xF1\xF2\xF3\xF4\xF5\xF6\xF7\xF8\xF9\xFA\xFB\xFC\xFD\xFE\xFF'
    When run expand_split_constants src/const/str/SX_STR_PRINTABLE.m4
    The status should be success
    The output should equal "readonly SX_STR_PRINTABLE=\$'${ascii}${gr}'"
  End

  It 'バイト集合をドル単一引用符で一つだけ宣言すること'
    control=$(printf '\001\002\003\004\005\006\007\010\011\012\013\014\015\016\017\020\021\022\023\024\025\026\027\030\031\032\033\034\035\036\037')
    ascii=' !"#$%&\'\''()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~'
    del=$(printf '\177')
    nonascii='\x80\x81\x82\x83\x84\x85\x86\x87\x88\x89\x8A\x8B\x8C\x8D\x8E\x8F\x90\x91\x92\x93\x94\x95\x96\x97\x98\x99\x9A\x9B\x9C\x9D\x9E\x9F\xA0\xA1\xA2\xA3\xA4\xA5\xA6\xA7\xA8\xA9\xAA\xAB\xAC\xAD\xAE\xAF\xB0\xB1\xB2\xB3\xB4\xB5\xB6\xB7\xB8\xB9\xBA\xBB\xBC\xBD\xBE\xBF\xC0\xC1\xC2\xC3\xC4\xC5\xC6\xC7\xC8\xC9\xCA\xCB\xCC\xCD\xCE\xCF\xD0\xD1\xD2\xD3\xD4\xD5\xD6\xD7\xD8\xD9\xDA\xDB\xDC\xDD\xDE\xDF\xE0\xE1\xE2\xE3\xE4\xE5\xE6\xE7\xE8\xE9\xEA\xEB\xEC\xED\xEE\xEF\xF0\xF1\xF2\xF3\xF4\xF5\xF6\xF7\xF8\xF9\xFA\xFB\xFC\xFD\xFE\xFF'
    When run expand_split_constants src/const/str/SX_STR_BYTE.m4
    The status should be success
    The output should equal "readonly SX_STR_BYTE=\$'${control}${ascii}${del}${nonascii}'"
  End

  It '受理パターンを一項目だけ出力すること'
    When run expand_split_constants src/const/cfg/SX_CFG_META_PATTERN_NUM_RANGE.m4
    The status should be success
    The output should equal "readonly SX_CFG_META_PATTERN_NUM_RANGE='32|64|128'"
  End

  It '制御文字全体の集合をドル単一引用符で一つだけ宣言すること'
    c0=$(printf '\001\002\003\004\005\006\007\010\011\012\013\014\015\016\017\020\021\022\023\024\025\026\027\030\031\032\033\034\035\036\037\177')
    c1='\x80\x81\x82\x83\x84\x85\x86\x87\x88\x89\x8A\x8B\x8C\x8D\x8E\x8F\x90\x91\x92\x93\x94\x95\x96\x97\x98\x99\x9A\x9B\x9C\x9D\x9E\x9F'
    When run expand_split_constants src/const/str/SX_STR_CONTROL.m4
    The status should be success
    The output should equal "readonly SX_STR_CONTROL=\$'${c0}${c1}'"
  End

  It 'QM の最終桁の定数だけを出力すること'
    When run expand_split_constants src/const/num/SX_NUM_QM_37.m4
    The status should be success
    The output should equal "readonly SX_NUM_QM_37='?????????????????????????????????????'"
  End

  It 'ZR の最初の桁の定数だけを出力すること'
    When run expand_split_constants src/const/num/SX_NUM_ZR_1.m4
    The status should be success
    The output should equal 'readonly SX_NUM_ZR_1=0'
  End

  It 'LF を含む定数だけを複数行の宣言として出力すること'
    expected="readonly SX_STR_LF='
'"
    When run expand_split_constants src/const/str/SX_STR_LF.m4
    The status should be success
    The output should equal "${expected}"
  End

  It 'URI の基本集合を単独で出力すること'
    When run expand_split_constants src/const/uri/SX_URI_UNRESERVED.m4
    The status should be success
    The output should equal "readonly SX_URI_UNRESERVED='-.0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz~'"
  End

  It 'URI の区切り文字集合を引用して単独で出力すること'
    expected="readonly SX_URI_SUB_DELIMS='!\$&'\\''()*+,;='"
    When run expand_split_constants src/const/uri/SX_URI_SUB_DELIMS.m4
    The status should be success
    The output should equal "${expected}"
  End

  It 'URI の英字集合をクォートせず単独で出力すること'
    When run expand_split_constants src/const/uri/SX_URI_SCHEME_FIRST.m4
    The status should be success
    The output should equal 'readonly SX_URI_SCHEME_FIRST=ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'
  End

  It 'URI のポート集合を DIGIT と同じ値で単独で出力すること'
    When run expand_split_constants src/const/uri/SX_URI_PORT.m4
    The status should be success
    The output should equal 'readonly SX_URI_PORT=0123456789'
  End

  It '複数行の定数を含む全定数の値が元の展開結果と一致すること'
    When call compare_split_constants
    The status should be success
  End
End
