#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_str_sub (eqc)'
  Include ./spec/support/run.sh
  # 検証に使うフラグ定数は、対象モジュールの依存とは別に準備する。
  sxtest_run SX_STR_SUB_EQC -- ''
  sxtest_load ./build/modules/sx_str_sub.sh

  It 'C ロケールでは英字の大小を区別してリテラル一致すること'
    When call sx_str_sub res: "Hello World" "hello" "earth" "${SX_NUM_I32_MAX}" "${SX_STR_SUB_EQC}"
    The variable res should equal "Hello World"
  End

  It '等価クラスで一致し置換すること'
    When call sx_str_sub res: "hello world" "llo" "XYZ" "${SX_NUM_I32_MAX}" "${SX_STR_SUB_EQC}"
    The variable res should equal "heXYZ world"
  End

  It 'グロブ特殊文字はリテラルとして扱うこと'
    When call sx_str_sub res: "a?b*c" "?" "Q" "${SX_NUM_I32_MAX}" "${SX_STR_SUB_EQC}"
    The variable res should equal "aQb*c"
  End

  It '括弧表現はリテラルとして扱うこと'
    When call sx_str_sub res: "a[0-9]b" "[0-9]" "X" "${SX_NUM_I32_MAX}" "${SX_STR_SUB_EQC}"
    The variable res should equal "aXb"
  End

  It '後方制限付きでeqc置換すること'
    # 後方から2つの 'a' を置換 (位置 2, 1)
    When call sx_str_sub res: "aaabbb" "a" "X" -2 "${SX_STR_SUB_EQC}"
    The variable res should equal "aXXbbb"
  End
End
