#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe '2進数字の文字列判定'
  sxtest_load ./build/modules/sx_str_is_bin.sh

  Context '2進数字以外の入力'
    Parameters:matrix
      sx_str_is_bin __sx_str_is_bin
      '' '2' '102' 'a' '0b101' '0B101' '+1' '-1' ' 01' '01 ' '0 1' '0	1' '０１' '*' '[01]'
    End

    It '不一致として1を返すこと'
      When call "$1" "$2"
      The status should equal 1
    End
  End

  Context '引数列と境界条件'
    Parameters
      sx_str_is_bin
      __sx_str_is_bin
    End

    It '単一文字、先頭ゼロ、複数の文字列を受理すること'
      When call "$1" '0' '1' '01' '10' '00101' '000' '111'
      The status should equal 0
    End

    It '引数がない場合に成功すること'
      When call "$1"
      The status should equal 0
    End

    It '改行を含む文字列を不一致として返すこと'
      bin_with_lf='0
1'
      When call "$1" "${bin_with_lf}"
      The status should equal 1
    End

    It '途中の引数が不一致の場合に1を返すこと'
      When call "$1" '01' '2' '10'
      The status should equal 1
    End

    It '途中の引数が空文字列の場合に1を返すこと'
      When call "$1" '01' '' '10'
      The status should equal 1
    End

    It '算術域を超える長い文字列を受理すること'
      long_bin='01'
      for step in 1 2 3 4 5 6 7 8 9; do
        long_bin="${long_bin}${long_bin}"
      done
      When call "$1" "${long_bin}"
      The status should equal 0
    End
  End
End
