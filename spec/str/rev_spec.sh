#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_str_rev()'
  Include ./sx.sh

  BeforeRun 'PATH=""'

  It '通常の文字列を反転すること'
    When call sx_str_rev res "hello"
    The variable res should equal "olleh"
  End

  It '空文字列を処理できること'
    When call sx_str_rev res ""
    The variable res should equal ""
  End

  It '1文字の文字列を処理できること'
    When call sx_str_rev res "a"
    The variable res should equal "a"
  End

  It 'メタ文字 (*, ?, [, ]) を含む文字列を反転できること'
    When call sx_str_rev res "a*b?c[d]"
    The variable res should equal "]d[c?b*a"
  End

  It '空白を含む文字列を反転できること'
    When call sx_str_rev res "a b c"
    The variable res should equal "c b a"
  End

  It '特殊文字（! @ # $ % ^ &）を含む文字列を反転できること'
    When call sx_str_rev res "!@#\$%^&"
    The variable res should equal "&^%\$#@!"
  End

  It 'シングルクォートを含む文字列を反転できること'
    When call sx_str_rev res "a'b'c"
    The variable res should equal "c'b'a"
  End

  It '読み取り専用の結果変数に対してエラーを返すこと'
    readonly MYRO_REV=1
    When call sx_str_rev MYRO_REV "abc"
    The status should equal 77
  End

  It '引数がない場合も空文字列を返すこと'
    When call sx_str_rev res
    The variable res should equal ""
  End

  It '引数1つ（結果変数のみ）で正しく動作すること'
    When call sx_str_rev res
    The variable res should equal ""
  End

  It '非常に長い文字列（1000文字）を反転できること'
    long_str_rev=$(printf 'a%.0s' $(seq 1 1000))
    When call sx_str_rev res "${long_str_rev}"
    The variable res should equal "${long_str_rev}"
  End

  It '回文（palindrome）が正しく反転されること'
    When call sx_str_rev res "たけやぶやけた"
    The variable res should equal "たけやぶやけた"
  End

  It '数字列を反転できること'
    When call sx_str_rev res "1234567890"
    The variable res should equal "0987654321"
  End

  It '改行を含む文字列を反転できること'
    newline_str_rev_input="a
b"
    newline_str_rev_expected="b
a"
    When call sx_str_rev res "${newline_str_rev_input}"
    The variable res should equal "${newline_str_rev_expected}"
  End
End
