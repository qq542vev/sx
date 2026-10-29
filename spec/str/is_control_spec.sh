#!/bin/sh
# shellcheck disable=SC3003 # 制御文字にはPOSIX.1-2024のドル単一引用符を使用する。

eval "$(shellspec - -c) exit 1"

Describe 'sx_str_is_control / __sx_str_is_control'
  sxtest_load ./build/modules/sx_str_is_control.sh

  Context 'C0・C1・DELのみの文字列'
    Parameters:matrix
      sx_str_is_control __sx_str_is_control
      $'\001\002\003\004\005\006\007\010\011\012\013\014\015\016\017\020\021\022\023\024\025\026\027\030\031\032\033\034\035\036\037\177' $'\200\201\202\203\204\205\206\207\210\211\212\213\214\215\216\217\220\221\222\223\224\225\226\227\230\231\232\233\234\235\236\237' $'\001\200\177\237' $'\205\012\233\033' $'\201\204\231'
    End

    It 'それぞれの領域の全値と混在する文字列を受理すること'
      When call "$1" "$2"
      The status should equal 0
    End
  End

  Context '制御文字以外の入力'
    Parameters:matrix
      sx_str_is_control __sx_str_is_control
      '' 'a' 'Z' '0' ' ' '~' '*' '?' '[' ']' '-' '^' '\' "'" '"' '$' '`' '\x80' $'\240' $'\377' 'é' '日本語' '😀'
    End

    It '不一致として1を返すこと'
      When call "$1" "$2"
      The status should equal 1
    End
  End

  Context '引数列と境界条件'
    Parameters
      sx_str_is_control
      __sx_str_is_control
    End

    It 'C0・C1・DELを異なる引数に分けても受理すること'
      When call "$1" $'\001\037' $'\200\237' $'\177\205\012'
      The status should equal 0
    End

    It '引数がない場合、0を返すこと'
      When call "$1"
      The status should equal 0
    End

    It '先頭の引数が空文字列の場合、1を返すこと'
      When call "$1" '' $'\001' $'\237'
      The status should equal 1
    End

    It '途中の引数が空文字列の場合、1を返すこと'
      When call "$1" $'\001' '' $'\237'
      The status should equal 1
    End

    It '最後の引数が空文字列の場合、1を返すこと'
      When call "$1" $'\001' $'\237' ''
      The status should equal 1
    End

    It '先頭に範囲外のバイトが混在する場合、1を返すこと'
      When call "$1" $'\040\037' $'\237'
      The status should equal 1
    End

    It '途中に範囲外のバイトが混在する場合、1を返すこと'
      When call "$1" $'\001\176\237'
      The status should equal 1
    End

    It '末尾に範囲外のバイトが混在する場合、1を返すこと'
      When call "$1" $'\001' $'\237\240'
      The status should equal 1
    End

    It '途中の引数が範囲外の場合、1を返すこと'
      When call "$1" $'\001' 'a' $'\237'
      The status should equal 1
    End

    It '長いC0・C1の混在文字列を受理すること'
      long_control=$'\001\200\177\237'
      for step in 1 2 3 4 5 6 7 8; do
        long_control="${long_control}${long_control}"
      done
      When call "$1" "${long_control}"
      The status should equal 0
    End
  End
End
