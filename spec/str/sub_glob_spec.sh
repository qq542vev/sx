#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_str_sub (glob)'
  Include ./sx.sh

  It 'globパターン（文字クラス）で置換すること'
    When call sx_str_sub res "a1b2c3d" "[0-9]" "X" "${SX_NUM_I32_MAX}" "${SX_STR_SUB_GLOB}"
    The variable res should equal "aXbXcXd"
  End

  It 'globパターン（ワイルドカード）で置換すること'
    When call sx_str_sub res "a*b*c" "[*]" "X" "${SX_NUM_I32_MAX}" "${SX_STR_SUB_GLOB}"
    The variable res should equal "aXbXc"
  End

  It '前方制限付きでglob置換すること'
    When call sx_str_sub res "a1b2c3d" "[0-9]" "X" 2 "${SX_STR_SUB_GLOB}"
    The variable res should equal "aXbXc3d"
  End

  It '後方制限付きでglob置換すること'
    When call sx_str_sub res "a1b2c3d" "[0-9]" "X" -2 "${SX_STR_SUB_GLOB}"
    The variable res should equal "a1bXcXd"
  End

  It '複雑なglobパターンで置換すること'
    When call sx_str_sub res "abc123def456ghi" "[0-9][0-9][0-9]" "###" "${SX_NUM_I32_MAX}" "${SX_STR_SUB_GLOB}"
    The variable res should equal "abc###def###ghi"
  End

  It 'デフォルト（フラグなし）ではリテラルとして扱うこと'
    # "[0-9]" という文字列をリテラルとして探すが、見つからないはず
    When call sx_str_sub res "a1b" "[0-9]" "X"
    The variable res should equal "a1b"
  End

  It 'フラグなしでリテラル置換が引き続き動作すること'
    When call sx_str_sub res "a[0-9]b" "[0-9]" "X"
    The variable res should equal "aXb"
  End
End
