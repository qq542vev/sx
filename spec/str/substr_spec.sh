#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_str_substr()'
  Include ./sx.sh

  BeforeRun 'PATH=""'

  It '文字列の中間から部分文字列を抽出すること'
    When call sx_str_substr res "abcdef" 2 3
    The variable res should equal "cde"
  End

  It '文字列の先頭から抽出すること'
    When call sx_str_substr res "abcdef" 0 3
    The variable res should equal "abc"
  End

  It '長さが省略された場合に末尾まで抽出すること'
    When call sx_str_substr res "abcdef" 2
    The variable res should equal "cdef"
  End

  It '長さが残りを超える場合に末尾まで抽出すること'
    When call sx_str_substr res "abcdef" 4 10
    The variable res should equal "ef"
  End

  It 'オフセットが文字列長を超える場合に空文字列を返すこと'
    When call sx_str_substr res "abc" 5 2
    The variable res should equal ""
  End

  It '長さが0の場合に空文字列を返すこと'
    When call sx_str_substr res "abcdef" 2 0
    The variable res should equal ""
  End

  It 'メタ文字 (*, ?, [) を含む文字列を処理できること'
    When call sx_str_substr res "a*b?c[d" 1 3
    The variable res should equal "*b?"
  End

  It '空のソース文字列を処理できること'
    When call sx_str_substr res "" 0 5
    The variable res should equal ""
  End

  It '数値ではないオフセットに対してエラーを返すこと'
    When call sx_str_substr res "abc" "x"
    The status should equal 64
  End

  It '数値ではない長さに対してエラーを返すこと'
    When call sx_str_substr res "abc" 1 "y"
    The status should equal 64
  End

  It '読み取り専用の結果変数に対してエラーを返すこと'
    readonly MYRO_SUBSTR=1
    When call sx_str_substr MYRO_SUBSTR "abc" 0 1
    The status should equal 77
  End

  It '負のオフセットで末尾から抽出すること'
    When call sx_str_substr res "abcdef" -3
    The variable res should equal "def"
  End

  It '負のオフセットが全長を超える場合に先頭から抽出すること'
    When call sx_str_substr res "abcdef" -10
    The variable res should equal "abcdef"
  End

  It '負の長さで末尾の文字を除外すること'
    When call sx_str_substr res "abcdef" 0 -2
    The variable res should equal "abcd"
  End

  It '負のオフセットと負の長さの両方を処理できること'
    When call sx_str_substr res "abcdef" -4 -1
    The variable res should equal "cde"
  End

  It '負の長さですべての文字が除外される場合に空文字列を返すこと'
    When call sx_str_substr res "abc" 1 -5
    The variable res should equal ""
  End

  It '非常に長い文字列（1000文字）から部分抽出できること'
    long_str_sub=$(printf 'a%.0s' $(seq 1 1000))
    When call sx_str_substr res "${long_str_sub}" 100 10
    The variable res should equal "aaaaaaaaaa"
  End

  It 'オフセットと長さに巨大な値を指定しても安全に動作すること'
    When call sx_str_substr res "abc" 999999999 999999999
    The variable res should equal ""
  End

  It '文字列を省略した場合に空文字列を返すこと'
    When call sx_str_substr res
    The status should be success
    The variable res should equal ""
  End

  It 'オフセットを省略した場合に全文字列を返すこと'
    When call sx_str_substr res "abcdef"
    The status should be success
    The variable res should equal "abcdef"
  End

  It '負のオフセットでメタ文字をリテラルとして扱うこと'
    When call sx_str_substr res "a*b?c[d]" -6 4
    The status should be success
    The variable res should equal "b?c["
  End

  It '日本語のオフセットと長さを文字単位で扱うこと'
    When call sx_str_substr res "あいうえお" -3 +2
    The status should be success
    The variable res should equal "うえ"
  End

  It '結果変数に元文字列の変数を使い回せること'
    res="a*b?c[d]"
    When call sx_str_substr res "$res" -6 4
    The status should be success
    The variable res should equal "b?c["
  End

  It '長い文字列の末尾から短い部分文字列を抽出できること'
    long_substr="a*b?c[d]"
    for substr_span in 1 2 3 4 5 6 7 8 9 10 11 12; do
      long_substr="${long_substr}${long_substr}"
    done

    When call sx_str_substr res "$long_substr" -8 4
    The status should be success
    The variable res should equal "a*b?"
  End

  It '呼び出し側で16進数を10進表記に変換すれば受理すること'
    When call sx_str_substr res "abcdef" "$((0x2))" "$((0x3))"
    The status should be success
    The variable res should equal "cde"
  End

  Context '符号と文字列長の境界'
    Parameters
      '+2' '+3' 'cde'
      '-3' '+2' 'de'
      '+0' '3' 'abc'
      '-0' '3' 'abc'
      '2' '+0' ''
      '2' '-0' ''
      '6' '2' ''
      '-6' '2' 'ab'
      '5' '1' 'f'
      '-1' '1' 'f'
      '2' '4' 'cdef'
      '2' '-4' ''
      '2' '-3' 'c'
      '2' '-5' ''
      '0' '+6' 'abcdef'
      '0' '-6' ''
    End

    It "オフセット $1、長さ $2 を処理できること"
      When call sx_str_substr res "abcdef" "$1" "$2"
      The status should be success
      The variable res should equal "$3"
    End
  End

  Context '算術範囲の最大値・最小値'
    Parameters
      32 2147483647 -2147483648
      64 9223372036854775807 -9223372036854775808
    End

    It '最大値の範囲内で先頭より前の部分を差し引くこと'
      sx_cfg_set "NUM_RANGE=$1"
      When call sx_str_substr res 'abcde' "-$2" "$2"
      The status should be success
      The variable res should equal 'abcde'
      The stderr should equal ''
    End

    It '最小値の絶対値を多倍長で扱い交差部分を抽出すること'
      sx_cfg_set "NUM_RANGE=$1"
      When call sx_str_substr res 'abcde' "$3" "$2"
      The status should be success
      The variable res should equal 'abcd'
      The stderr should equal ''
    End

    It '最小値の長さですべての文字を除外すること'
      sx_cfg_set "NUM_RANGE=$1"
      When call sx_str_substr res 'abcde' 0 "$3"
      The status should be success
      The variable res should equal ''
      The stderr should equal ''
    End
  End

  Context '数値範囲を超える引数'
    Before 'sx_cfg_set NUM_RANGE=32'
    Before 'guard_substr_pattern'

    guard_substr_pattern() {
      substr_pattern_generated=0
      # 回帰時にも巨大なパターンを割り当てず、生成の有無を検出する。
      __sx_str_qm() {
        substr_pattern_generated=1
        eval "${1}='?'"
      }
    }

    Parameters
      '2147483648'
      '9223372036854775808'
      '1000000000000000000000000000000'
    End

    It "巨大な正のオフセット $1 で空文字列を返すこと"
      When call sx_str_substr res "abcdef" "+$1"
      The status should be success
      The variable res should equal ""
      The variable substr_pattern_generated should equal 0
      The stderr should equal ''
    End

    It "巨大な負のオフセット -$1 で先頭から抽出すること"
      When call sx_str_substr res "abcdef" "-$1"
      The status should be success
      The variable res should equal "abcdef"
      The variable substr_pattern_generated should equal 0
      The stderr should equal ''
    End

    It "巨大な正の長さ $1 で末尾まで抽出すること"
      When call sx_str_substr res "abcdef" 0 "+$1"
      The status should be success
      The variable res should equal "abcdef"
      The variable substr_pattern_generated should equal 0
      The stderr should equal ''
    End

    It "巨大な負の長さ -$1 ですべての文字を除外すること"
      When call sx_str_substr res "abcdef" 0 "-$1"
      The status should be success
      The variable res should equal ""
      The variable substr_pattern_generated should equal 0
      The stderr should equal ''
    End

    It 'オフセットと長さがともに巨大な負数の場合に空文字列を返すこと'
      When call sx_str_substr res "abcdef" "-$1" "-$1"
      The status should be success
      The variable res should equal ""
      The variable substr_pattern_generated should equal 0
      The stderr should equal ''
    End

    It '空文字列に巨大な数値を指定してもパターンを生成しないこと'
      When call sx_str_substr res "" "$1" "-$1"
      The status should be success
      The variable res should equal ""
      The variable substr_pattern_generated should equal 0
      The stderr should equal ''
    End
  End

  Context 'Perl と同じ範囲抽出（undef は空文字列）'
    Parameters
      '-8' '2' ''
      '-8' '3' ''
      '-8' '4' 'a'
      '-8' '+5' 'ab'
      '-8' '8' 'abcde'
      '-8' '-1' 'abcd'
      '-8' '-6' ''
      '-8' '0' ''
      '-8' '-0' ''
      '5' '2' ''
      '6' '2' ''
      '6' '0' ''
      '-1000000000000000000000000000000' '999999999999999999999999999996' 'a'
      '-1000000000000000000000000000000' '999999999999999999999999999995' ''
      '-1000000000000000000000000000000' '999999999999999999999999999994' ''
    End

    It "オフセット $1、長さ $2 の交差部分を警告なしで返すこと"
      sx_cfg_set NUM_RANGE=32
      res=before
      When call sx_str_substr res 'abcde' "$1" "$2"
      The status should be success
      The variable res should equal "$3"
      The stdout should equal ''
      The stderr should equal ''
    End
  End

  It '検証を省略しても巨大な数値を処理できること'
    sx_cfg_set SKIP_CHK=1
    When call sx_str_substr res "abcdef" -1000000000000000000000000000000 +1000000000000000000000000000000
    The status should be success
    The variable res should equal "abcdef"
  End

  Context '10進表記以外または不正な数値引数'
    Parameters
      ''
      '00'
      '010'
      '08'
      '+010'
      '-010'
      '0xb'
      '0XB'
      '+0xb'
      '-0xb'
      '1.5'
      '1e2'
      '2+1'
      ' 3'
      '+'
      '-'
    End

    It "オフセット <$1> を64で拒否して結果変数を変更しないこと"
      res=before
      When call sx_str_substr res "abcdef" "$1" 2
      The status should equal 64
      The variable res should equal "before"
      The stdout should equal ''
      The stderr should equal ''
    End

    It "長さ <$1> を64で拒否して結果変数を変更しないこと"
      res=before
      When call sx_str_substr res "abcdef" 2 "$1"
      The status should equal 64
      The variable res should equal "before"
      The stdout should equal ''
      The stderr should equal ''
    End
  End
End
