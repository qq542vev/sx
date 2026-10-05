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

  It 'チャンクサイズ >0 で先頭基準のチャンク反転ができること'
    When call sx_str_rev res "abcdefghi" 3
    The variable res should equal "ghidefabc"
  End

  It 'チャンクサイズ >0, 非倍数長の文字列を扱えること'
    When call sx_str_rev res "abcdefgh" 3
    The variable res should equal "ghdefabc"
  End

  It 'チャンクサイズ >0, 短い文字列を扱えること'
    When call sx_str_rev res "abc" 2
    The variable res should equal "cab"
  End

  It 'チャンクサイズ <0 で末尾基準のチャンク反転ができること'
    When call sx_str_rev res "abcdefghi" -3
    The variable res should equal "ghidefabc"
  End

  It 'チャンクサイズ <0, 非倍数長の文字列を扱えること'
    When call sx_str_rev res "abcdefgh" -3
    The variable res should equal "fghcdeab"
  End

  It 'チャンクサイズ <0, 短い文字列を扱えること'
    When call sx_str_rev res "abc" -2
    The variable res should equal "bca"
  End

  It 'チャンクサイズ 0 でエラーを返すこと'
    When call sx_str_rev res "abc" 0
    The status should equal 64
  End

  It 'チャンクサイズ 1 で従来の文字単位反転と同じ結果になること'
    When call sx_str_rev res "abcdefghi" 1
    The variable res should equal "ihgfedcba"
  End

  It 'チャンクサイズ -1 で従来の文字単位反転と同じ結果になること'
    When call sx_str_rev res "abcdefghi" -1
    The variable res should equal "ihgfedcba"
  End

  It '空のチャンクサイズで文字単位の反転を行うこと'
    When call sx_str_rev res "abc" ""
    The status should be success
    The variable res should equal "cba"
  End

  It '+1 で文字単位の反転を行うこと'
    When call sx_str_rev res "abc" +1
    The status should be success
    The variable res should equal "cba"
  End

  It '+ 付きのチャンクサイズで先頭基準の反転を行うこと'
    When call sx_str_rev res "abcdefgh" +3
    The status should be success
    The variable res should equal "ghdefabc"
  End

  It '呼び出し側で16進数を10進表記に変換すれば受理すること'
    When call sx_str_rev res "abcdefgh" "$((0x3))"
    The status should be success
    The variable res should equal "ghdefabc"
  End

  It '負方向のチャンク反転でメタ文字をリテラルとして扱うこと'
    When call sx_str_rev res "a*b?c[d]" -6
    The status should be success
    The variable res should equal "b?c[d]a*"
  End

  It '正方向のチャンク反転でメタ文字をリテラルとして扱うこと'
    When call sx_str_rev res "a*b?c[d]" +3
    The status should be success
    The variable res should equal "d]?c[a*b"
  End

  Context '文字列長以上のチャンクサイズ'
    Before 'sx_cfg_set NUM_RANGE=32'

    Parameters
      '3'
      '+3'
      '-3'
      '4'
      '+4'
      '-4'
      '2147483648'
      '+2147483648'
      '-2147483648'
      '9223372036854775809'
      '+9223372036854775809'
      '-9223372036854775809'
      '1000000000000000000000000000000'
      '+1000000000000000000000000000000'
      '-1000000000000000000000000000000'
    End

    It "サイズ $1 でパターンを生成せず元文字列を返すこと"
      rev_pattern_generated=0
      # 回帰時にも巨大なパターンを割り当てず、生成の有無を検出する。
      __sx_str_qm() {
        rev_pattern_generated=1
        eval "${1}='?'"
      }

      When call sx_str_rev res "abc" "$1"
      The status should be success
      The variable res should equal "abc"
      The variable rev_pattern_generated should equal 0
      The stdout should equal ''
      The stderr should equal ''
    End
  End

  Context '空文字列と巨大なチャンクサイズ'
    Before 'sx_cfg_set NUM_RANGE=32'

    Parameters
      '1000000000000000000000000000000'
      '+1000000000000000000000000000000'
      '-1000000000000000000000000000000'
    End

    It "サイズ $1 を受理して空文字列を返すこと"
      When call sx_str_rev res "" "$1"
      The status should be success
      The variable res should equal ""
      The stdout should equal ''
      The stderr should equal ''
    End
  End

  Context '10進表記以外または不正なチャンクサイズ'
    Parameters
      '+0'
      '-0'
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
      'abc'
    End

    It "サイズ <$1> を64で拒否して結果変数を変更しないこと"
      res=before
      When call sx_str_rev res "abc" "$1"
      The status should equal 64
      The variable res should equal "before"
      The stdout should equal ''
      The stderr should equal ''
    End
  End
End
