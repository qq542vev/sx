#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_str_quote'
  Include ./sx.sh

  It '通常の文字列をシングルクォートで囲むこと'
    sx_str_quote res "abc"
    The variable res should equal "'abc'"
  End

  It '空文字列を入力すると空クォートを返すこと'
    sx_str_quote res ""
    The variable res should equal "''"
  End

  It '第2引数を省略すると空クォートを返すこと'
    sx_str_quote res
    The variable res should equal "''"
  End

  It '内部のシングルクォートをエスケープすること'
    sx_str_quote res "a'b"
    The variable res should equal "'a'\\''b'"
  End

  It '先頭のシングルクォートをエスケープすること'
    sx_str_quote res "'abc"
    The variable res should equal "''\\''abc'"
  End

  It '末尾のシングルクォートをエスケープすること'
    sx_str_quote res "abc'"
    The variable res should equal "'abc'\\'''"
  End

  It '連続したシングルクォートをエスケープすること'
    sx_str_quote res "a''b"
    The variable res should equal "'a'\\'''\\''b'"
  End

  It '連続して呼び出しても前回の影響を受けないこと'
    sx_str_quote res1 "a'b"
    sx_str_quote res2 "xyz"
    The variable res1 should equal "'a'\\''b'"
    The variable res2 should equal "'xyz'"
  End

  It '無効な結果変数名に対して EX_USAGE を返すこと'
    When call sx_str_quote "1invalid" "abc"
    The status should equal 64
  End

  It '結果変数が読み取り専用の場合に EX_NOPERM を返すこと'
    readonly ro_res_quote="fixed"
    When call sx_str_quote ro_res_quote "abc"
    The status should equal 77
  End

  It 'SX_CFG_SKIP_CHK=1 の時に高速モードで動作すること'
    SX_CFG_SKIP_CHK=1 sx_str_quote res "a'b"
    The variable res should equal "'a'\\''b'"
  End
End
