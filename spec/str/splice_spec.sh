#!/bin/sh

eval "$(shellspec - -c) exit 1"

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

  It '先頭より前だけの削除範囲では先頭に挿入すること'
    sx_str_splice res "abcde" -10 1 "X"
    The variable res should equal "Xabcde"
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
  Context 'substr と同じ削除範囲と多倍長引数'
    Parameters
      '-5' '2' 'Xbcd'
      '-5' '1' 'Xabcd'
      '-5' '6' 'X'
      '-5' '-1' 'Xd'
      '-4' '2' 'Xcd'
      '+0' '-0' 'Xabcd'
      '-0' '+2' 'Xcd'
      '4' '2' 'abcdX'
      '1000000000000000000000000000000' '2' 'abcdX'
      '-1000000000000000000000000000000' '999999999999999999999999999997' 'Xbcd'
      '-1000000000000000000000000000000' '999999999999999999999999999996' 'Xabcd'
      '-1000000000000000000000000000000' '1000000000000000000000000000000' 'X'
      '1' '1000000000000000000000000000000' 'aX'
      '1' '-1000000000000000000000000000000' 'aXbcd'
      '-2147483648' '2147483647' 'Xd'
    End

    It "開始位置 $1、削除数 $2 を処理すること"
      sx_cfg_set NUM_RANGE=32
      When call sx_str_splice res 'abcd' "$1" "$2" 'X'
      The status should be success
      The variable res should equal "$3"
      The stderr should equal ''
    End
  End

  It '先頭より前からの削除範囲の交差部分だけ削除すること'
    When call sx_str_splice res 'abcd' -5 2
    The status should be success
    The variable res should equal 'bcd'
  End

  It '削除数の省略で末尾まで削除すること'
    When call sx_str_splice res 'abcd' -2
    The status should be success
    The variable res should equal 'ab'
  End

  It '巨大な負の開始位置でも削除数の省略で全削除すること'
    When call sx_str_splice res 'abcd' -1000000000000000000000000000000
    The status should be success
    The variable res should equal ''
  End

  It '結果変数だけでも成功すること'
    When call sx_str_splice res
    The status should be success
    The variable res should equal ''
  End

  It '空文字列にも挿入できること'
    When call sx_str_splice res '' -5 2 X
    The status should be success
    The variable res should equal 'X'
  End

  It '検証省略時にも多倍長の範囲を扱うこと'
    sx_cfg_set SKIP_CHK=1
    res=abcd
    When call sx_str_splice res "$res" -1000000000000000000000000000000 999999999999999999999999999997
    The status should be success
    The variable res should equal 'bcd'
  End

  Context '空の数値引数は既定値として扱う'
    Parameters
      '' '2' 'Xcd'
      '' '0' 'Xabcd'
      '' '-1' 'Xd'
      '2' '' 'abX'
      '' '' 'X'
      '-5' '' 'X'
    End

    It '開始位置と削除数の引数位置を維持すること'
      When call sx_str_splice res abcd "$1" "$2" X
      The status should be success
      The variable res should equal "$3"
    End

    It '検証を省略しても同じ既定値で処理すること'
      sx_cfg_set SKIP_CHK=1
      When call sx_str_splice res abcd "$1" "$2" X
      The status should be success
      The variable res should equal "$3"
    End
  End

  Context '不正な数値表記'
    Parameters
      '02'
      '0x2'
      '+01'
      '-01'
      '1+1'
    End

    It '開始位置を拒否し結果を保持すること'
      res=before
      When call sx_str_splice res abcd "$1" 2
      The status should equal 64
      The variable res should equal before
    End

    It '削除数を拒否し結果を保持すること'
      res=before
      When call sx_str_splice res abcd 2 "$1"
      The status should equal 64
      The variable res should equal before
    End
  End
End
