#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_str_split'
  Include ./sx.sh
  It '文字列を分割して結果変数に格納すること'
    When call sx_str_split res "a:b:c:d" ":"
    The status should be success
    The variable res should equal "'a' 'b' 'c' 'd'"
  End

  It '回数制限付きで前方から分割すること'
    When call sx_str_split res "a:b:c:d" ":" 2
    The status should be success
    The variable res should equal "'a' 'b' 'c:d'"
  End

  It '回数制限付きで後方から分割すること'
    When call sx_str_split res "a:b:c:d" ":" -2
    The status should be success
    The variable res should equal "'a:b' 'c' 'd'"
  End

  It '特殊文字を処理できること'
    When call sx_str_split res "a'b:c\"d" ":" 1
    The status should be success
    The variable res should equal "'a'\''b' 'c\"d'"
  End

  It '空の入力文字列を処理できること'
    When call sx_str_split res "" ":" 5
    The status should be success
    The variable res should equal "''"
  End

  It '空文字を区切り文字とした場合に境界線モデルで分割すること'
    When call sx_str_split res "abcde" ""
    The status should be success
    The variable res should equal "'' 'a' 'b' 'c' 'd' 'e' ''"
  End

  It '空文字を区切り文字として制限付きで前方から分割すること'
    When call sx_str_split res "abcde" "" 3
    The status should be success
    The variable res should equal "'' 'a' 'b' 'cde'"
  End

  It '空文字を区切り文字として制限付きで後方から分割すること'
    When call sx_str_split res "abcde" "" -3
    The status should be success
    The variable res should equal "'abc' 'd' 'e' ''"
  End

  It '空文字を空文字で分割した場合に2つの要素を返すこと'
    When call sx_str_split res "" ""
    The status should be success
    The variable res should equal "'' ''"
  End

  It '空文字を区切り文字として制限1で前方から分割すること'
    When call sx_str_split res "A" "" 1
    The status should be success
    The variable res should equal "'' 'A'"
  End

  It 'glob モードで * のみの区切り文字は空区切り相当になること'
    sx_str_split res "abc" "*" "${SX_NUM_I32_MAX}" "${SX_STR_SPLIT_GLOB}"
    Assert sx_str_eq "${res}" "'' 'a' 'b' 'c' ''"
  End

  It '非 glob モードでは * はリテラルとして扱われること'
    sx_str_split res "abc" "*"
    Assert sx_str_eq "${res}" "'abc'"
  End

  It 'glob モードで * のみの区切り文字、空文字列の場合は空要素2つになること'
    sx_str_split res "" "*" "${SX_NUM_I32_MAX}" "${SX_STR_SPLIT_GLOB}"
    Assert sx_str_eq "${res}" "'' ''"
  End

  It 'glob モードで * のみの区切り文字、制限付き前方分割ができること'
    sx_str_split res "abcde" "*" 3 "${SX_STR_SPLIT_GLOB}"
    Assert sx_str_eq "${res}" "'' 'a' 'b' 'cde'"
  End

  It 'glob モードで * のみの区切り文字、制限付き後方分割ができること'
    sx_str_split res "abcde" "*" -3 "${SX_STR_SPLIT_GLOB}"
    Assert sx_str_eq "${res}" "'abc' 'd' 'e' ''"
  End
End
