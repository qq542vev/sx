#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_str_split'
  Include ./spec/support/run.sh
  # 検証に使うフラグ定数は、対象モジュールの依存とは別に準備する。
  sxtest_run SX_STR_SPLIT_GLOB SX_STR_SPLIT_INC SX_STR_SPLIT_ICASE SX_STR_SPLIT_EQ -- ''
  sxtest_load ./build/modules/sx_str_split.sh
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
    When call sx_str_split res "abc" "*" 2147483647 "${SX_STR_SPLIT_GLOB}"
    The status should be success
    The variable res should equal "'' 'a' 'b' 'c' ''"
  End

  It '非 glob モードでは * はリテラルとして扱われること'
    When call sx_str_split res "abc" "*"
    The status should be success
    The variable res should equal "'abc'"
  End

  It 'glob モードで * のみの区切り文字、空文字列の場合は空要素2つになること'
    When call sx_str_split res "" "*" 2147483647 "${SX_STR_SPLIT_GLOB}"
    The status should be success
    The variable res should equal "'' ''"
  End

  It 'glob モードで * のみの区切り文字、制限付き前方分割ができること'
    When call sx_str_split res "abcde" "*" 3 "${SX_STR_SPLIT_GLOB}"
    The status should be success
    The variable res should equal "'' 'a' 'b' 'cde'"
  End

  It 'glob モードで * のみの区切り文字、制限付き後方分割ができること'
    When call sx_str_split res "abcde" "*" -3 "${SX_STR_SPLIT_GLOB}"
    The status should be success
    The variable res should equal "'abc' 'd' 'e' ''"
  End

  It 'ICASE モードで英字の大小を区別せず分割すること'
    When call sx_str_split res "a1B2b3" "b" 2147483647 "${SX_STR_SPLIT_ICASE}"
    The status should be success
    The variable res should equal "'a1' '2' '3'"
  End

  It 'ICASE モードで区切り文字が見つからない場合は元のまま返すこと'
    When call sx_str_split res "xyz" "b" 2147483647 "${SX_STR_SPLIT_ICASE}"
    The status should be success
    The variable res should equal "'xyz'"
  End

  It 'EQ モードで等価クラスに基づき分割すること'
    When call sx_str_split res "a1b2a3" "a" 2147483647 "${SX_STR_SPLIT_EQ}"
    The status should be success
    The variable res should equal "'' '1b2' '3'"
  End

  It 'INC と ICASE を併用した場合に一致文字列を含めて分割すること'
    When call sx_str_split res "a1B2b3" "b" 2147483647 "$((SX_STR_SPLIT_INC | SX_STR_SPLIT_ICASE))"
    The status should be success
    The variable res should equal "'a1' 'B' '2' 'b' '3'"
  End
End

Describe '照合モードの排他'
  Include ./spec/support/run.sh
  sxtest_run SX_STR_SPLIT_GLOB SX_STR_SPLIT_ICASE SX_STR_SPLIT_EQ -- ''
  sxtest_load ./build/modules/sx_str_split.sh

  It 'ICASE と EQ の同時指定は Usage Error になること'
    When call sx_str_split res "abc" "a" "" "$((SX_STR_SPLIT_ICASE | SX_STR_SPLIT_EQ))"
    The status should equal "64"
  End

  It 'ICASE と GLOB の同時指定は Usage Error になること'
    When call sx_str_split res "abc" "a" "" "$((SX_STR_SPLIT_ICASE | SX_STR_SPLIT_GLOB))"
    The status should equal "64"
  End

  It 'EQ と GLOB の同時指定は Usage Error になること'
    When call sx_str_split res "abc" "a" "" "$((SX_STR_SPLIT_EQ | SX_STR_SPLIT_GLOB))"
    The status should equal "64"
  End
End
