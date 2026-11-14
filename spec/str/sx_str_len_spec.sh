#!/bin/sh
# shellcheck disable=SC2016 # CMD内の変数は準備用シェルで展開する。
eval "$(shellspec - -c) exit 1"

Describe 'sx_str_len'
  Include ./spec/support/run.sh
  sxtest_load ./build/modules/sx_str_len.sh

  It '各文字列の長さを順に代入すること'
    When call sx_str_len 'v1:v2:v3' 'abc' 'de' 'fghij'
    The status should be success
    The variable v1 should equal '3'
    The variable v2 should equal '2'
    The variable v3 should equal '5'
  End

  It '空のバインドでは何も代入せず成功すること'
    When call sx_str_len '' 'abc' 'de'
    The status should be success
  End

  It '文字列を指定しない場合は成功すること'
    When call sx_str_len 'v1:v2'
    The status should be success
  End

  It 'バインド先より文字列が多い場合は超過分を無視すること'
    When call sx_str_len 'v1' 'a' 'bb' 'ccc'
    The status should be success
    The variable v1 should equal '1 2 3'
  End

  It '文字列よりバインド先が多い場合は未到達変数を保持すること'
    When call sx_str_len 'v1:v2:v3' 'hi'
    The status should be success
    The variable v1 should equal '2'
    The variable v2 should be undefined
    The variable v3 should equal ''
  End

  It '結果変数が読み取り専用の場合は 77 を返すこと'
    readonly ro_var="init"
    When call sx_str_len 'ro_var' 'abc'
    The status should equal 77
  End

  It '不正なバインド形式の場合は 64 を返すこと'
    When call sx_str_len 'invalid!' 'abc'
    The status should equal 64
  End
End
