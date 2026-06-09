#!/bin/sh

Describe 'sx_str_splice'
  Include ./sx.sh

  It '文字列の途中に挿入できること (len=0)'
    sx_str_splice res "abcde" 2 0 "."
    The variable res should equal "ab.cde"
  End

  It '文字列の一部を削除できること (addstr="")'
    sx_str_splice res "abcde" 2 1 ""
    The variable res should equal "abde"
  End

  It '文字列の一部を置換できること'
    sx_str_splice res "abcde" 2 1 "X"
    The variable res should equal "abXde"
    
    sx_str_splice res "abcde" 1 3 "XYZ"
    The variable res should equal "aXYZe"
  End

  It '先頭に挿入できること'
    sx_str_splice res "abc" 0 0 "!"
    The variable res should equal "!abc"
  End

  It '末尾に挿入できること'
    sx_str_splice res "abc" 3 0 "!"
    The variable res should equal "abc!"
  End

  It '全削除と置換ができること'
    sx_str_splice res "abc" 0 3 "XYZ"
    The variable res should equal "XYZ"
  End

  It '負数の開始位置（末尾からのオフセット）をサポートすること'
    sx_str_splice res "abcde" -2 1 "X"
    The variable res should equal "abcXe"
  End

  It '文字列長を超える負数の開始位置を 0 にクランプすること'
    sx_str_splice res "abcde" -10 1 "X"
    The variable res should equal "Xbcde"
  End

  It '負数の削除数（末尾からの除外）をサポートすること'
    sx_str_splice res "abcde" 1 -1 "X"
    The variable res should equal "aXe"
  End

  It '開始位置と削除数の両方に負数を指定できること'
    sx_str_splice res "abcde" -4 -1 "X"
    The variable res should equal "aXe"
  End

  It '削除範囲が空になる場合（start >= end）を正しく扱うこと'
    sx_str_splice res "abcde" 2 -4 "X"
    The variable res should equal "abXcde"
  End

  It '文字列長を超える正の開始位置を末尾として扱うこと'
    sx_str_splice res "abc" 5 1 "X"
    The variable res should equal "abcX"
  End

  It '不正な数値引数でエラーを返すこと'
    When call sx_str_splice res "abc" "x" 0 "."
    The status should equal 64
  End

  It '元文字列にメタ文字（* ? [）が含まれる場合も正しくスプライスできること'
    When call sx_str_splice res "a*b?c[d" 2 1 "X"
    The variable res should equal "a*X?c[d"
  End

  It '挿入文字列にシングルクォートが含まれる場合も正しく処理できること'
    When call sx_str_splice res "abcd" 2 0 "it's"
    The variable res should equal "abit'scd"
  End

  It '非常に長い文字列でのスプライスが正しく動作すること'
    long_spl=$(printf 'a%.0s' $(seq 1 1000))
    When call sx_str_splice res "${long_spl}" 500 10 "X"
    The length of variable res should equal 991
  End
End
