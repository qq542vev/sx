#!/bin/sh
# shellcheck shell=sh
# shellcheck disable=SC2154,SC2286,SC2329
# shellcheck disable=SC2288 # Parameters 内の % で終わる文字列は入力データ。

Describe 'sx_uri_enc の個別版'
  Include ./build/modules/sx_uri_enc.sh

  encode_and_check() {
    sx_uri_enc result "$@"
    check_no_leak || return
    printf '%s\n' "$result"
  }

  Context '基本的な入力'
    Parameters
      'abcXYZ012-._~' 'abcXYZ012-._~'
      'a b/c+%' 'a%20b%2Fc%2B%25'
      "a'b" 'a%27b'
      '' ''
    End

    It '個別版だけでエンコードできること'
      When call sx_uri_enc result "$1"
      The status should be success
      The variable result should equal "$2"
      The stdout should equal ''
      The stderr should equal ''
    End
  End

  It 'テスト内で用意した改行を変換できること'
    input='first
next'
    When call sx_uri_enc result "$input"
    The status should be success
    The variable result should equal 'first%0Anext'
  End

  It '入力省略時に蓄積先を空にすること'
    result=before
    When call sx_uri_enc result
    The status should be success
    The variable result should equal ''
  End

  It '複数の入力を分配できること'
    When call sx_uri_enc 'item:rest' 'a b' 'c/d' 'e+f'
    The status should be success
    The variable item should equal 'a%20b'
    The variable rest should equal 'c%2Fd e%2Bf'
  End

  It 'バインド形式の省略を拒否すること'
    When call sx_uri_enc
    The status should equal 64
  End

  It '不正なバインド形式を拒否すること'
    When call sx_uri_enc 'invalid-name' 'a b'
    The status should equal 64
  End

  It '不正な数値範囲設定では結果を変更しないこと'
    SX_CFG_NUM_RANGE=invalid
    result=before
    When call sx_uri_enc result 'a b'
    The status should equal 78
    The variable result should equal before
  End

  It '検証省略時にも依存先を呼び出せること'
    SX_CFG_SKIP_CHK=1
    When call sx_uri_enc result 'a b'
    The status should be success
    The variable result should equal 'a%20b'
  End

  It '-efu を有効にしたシェルで動作し内部変数を解放すること'
    When run efu_run encode_and_check 'a b'
    The status should be success
    The stdout should equal 'a%20b'
    The stderr should equal ''
  End
End
