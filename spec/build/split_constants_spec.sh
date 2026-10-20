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
      split_script=$(expand_split_constants src/constants.m4) || exit
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

  It '合成定数だけを出力し、合成元の実行時定数を出力しないこと'
    When run expand_split_constants src/constants/str/SX_STR_ALNUM.m4
    The status should be success
    The output should equal 'readonly SX_STR_ALNUM=0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'
  End

  It '受理パターンを一項目だけ出力すること'
    When run expand_split_constants src/constants/cfg/SX_CFG_META_PATTERN_NUM_RANGE.m4
    The status should be success
    The output should equal "readonly SX_CFG_META_PATTERN_NUM_RANGE='32|64|128'"
  End

  It 'QM の最終桁の定数だけを出力すること'
    When run expand_split_constants src/constants/num/SX_NUM_QM_37.m4
    The status should be success
    The output should equal "readonly SX_NUM_QM_37='?????????????????????????????????????'"
  End

  It 'ZR の最初の桁の定数だけを出力すること'
    When run expand_split_constants src/constants/num/SX_NUM_ZR_1.m4
    The status should be success
    The output should equal 'readonly SX_NUM_ZR_1=0'
  End

  It 'LF を含む定数だけを複数行の宣言として出力すること'
    expected="readonly SX_STR_LF='
'"
    When run expand_split_constants src/constants/str/SX_STR_LF.m4
    The status should be success
    The output should equal "${expected}"
  End

  It '複数行の定数を含む全定数の値が元の展開結果と一致すること'
    When call compare_split_constants
    The status should be success
  End
End
