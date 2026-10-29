#!/bin/sh
# shellcheck disable=SC3003 # 制御文字にはPOSIX.1-2024のドル単一引用符を使用する。

eval "$(shellspec - -c) exit 1"

Describe 'sx_str_is_nonascii / __sx_str_is_nonascii'
  sxtest_load ./build/modules/sx_str_is_nonascii.sh

  Context '非ASCII文字だけの文字列'
    Parameters:matrix
      sx_str_is_nonascii __sx_str_is_nonascii
      'é' 'ÿ' 'Ā' '日本語' 'Ａ０' '😀' 'あé😀'
    End

    It '文字の範囲を0x80-0xFFに限定せず成功すること'
      When call "$1" "$2"
      The status should equal 0
    End
  End

  Context 'ASCII文字の混入'
    Parameters:matrix
      sx_str_is_nonascii __sx_str_is_nonascii
      'a' 'Z' '0' ' ' '[' ']' '-' '^' '!' '*' '?' '\' "'" '"' '$' '`' $'\001' $'\t' $'\n' $'\r' $'\177'
    End

    It '非ASCII文字と混在していても1を返すこと'
      When call "$1" "あ${2}い"
      The status should equal 1
    End
  End

  Context '引数列と空文字列'
    Parameters
      sx_str_is_nonascii
      __sx_str_is_nonascii
    End

    It '複数の非ASCII文字列を受理すること'
      When call "$1" 'あ' '日本語' 'é😀'
      The status should equal 0
    End

    It '引数がない場合、0を返すこと'
      When call "$1"
      The status should equal 0
    End

    It '空文字列の場合、1を返すこと'
      When call "$1" ''
      The status should equal 1
    End

    It '先頭の引数が空文字列の場合、1を返すこと'
      When call "$1" '' 'あ' 'い'
      The status should equal 1
    End

    It '途中の引数が空文字列の場合、1を返すこと'
      When call "$1" 'あ' '' 'い'
      The status should equal 1
    End

    It '最後の引数が空文字列の場合、1を返すこと'
      When call "$1" 'あ' 'い' ''
      The status should equal 1
    End

    It 'ASCII文字だけの場合、1を返すこと'
      When call "$1" 'abc123'
      The status should equal 1
    End

    It '先頭の引数にASCII文字がある場合、1を返すこと'
      When call "$1" 'aあ' 'い' 'う'
      The status should equal 1
    End

    It '途中の引数にASCII文字がある場合、1を返すこと'
      When call "$1" 'あ' 'いaう' 'え'
      The status should equal 1
    End

    It '最後の引数にASCII文字がある場合、1を返すこと'
      When call "$1" 'あ' 'い' 'うa'
      The status should equal 1
    End
  End
End
