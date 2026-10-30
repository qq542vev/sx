#!/bin/sh
# shellcheck disable=SC3003 # 制御文字にはPOSIX.1-2024のドル単一引用符を使用する。

eval "$(shellspec - -c) exit 1"

Describe 'sx_str_is_c0 / __sx_str_is_c0'
  sxtest_load ./build/modules/sx_str_is_c0.sh

  Context 'NULを除くC0領域の全31値'
    Parameters:matrix
      sx_str_is_c0 __sx_str_is_c0
      $'\001' $'\002' $'\003' $'\004' $'\005' $'\006' $'\007' $'\010' $'\011' $'\012' $'\013' $'\014' $'\015' $'\016' $'\017' $'\020' $'\021' $'\022' $'\023' $'\024' $'\025' $'\026' $'\027' $'\030' $'\031' $'\032' $'\033' $'\034' $'\035' $'\036' $'\037'
    End

    It '各値を受理すること'
      When call "$1" "$2"
      The status should equal 0
    End
  End

  Context 'C0領域以外と空文字列'
    Parameters:matrix
      sx_str_is_c0 __sx_str_is_c0
      '' 'a' '0' ' ' '~' '*' '?' '[' ']' '-' '^' '\' "'" '"' '$' '`' $'\177' $'\200' $'\237' $'\240' $'\377' '日本語'
    End

    It 'DELやC1も不一致として1を返すこと'
      When call "$1" "$2"
      The status should equal 1
    End
  End

  Context '引数列と境界条件'
    Parameters
      sx_str_is_c0
      __sx_str_is_c0
    End

    It '全31値を連結した文字列を受理すること'
      When call "$1" $'\001\002\003\004\005\006\007\010\011\012\013\014\015\016\017\020\021\022\023\024\025\026\027\030\031\032\033\034\035\036\037'
      The status should equal 0
    End

    It 'C0領域の複数の値と複数の引数を受理すること'
      When call "$1" $'\001\037' $'\011\012\015'
      The status should equal 0
    End

    It '引数がない場合、0を返すこと'
      When call "$1"
      The status should equal 0
    End

    It '先頭の引数が空文字列の場合、1を返すこと'
      When call "$1" '' $'\001' $'\037'
      The status should equal 1
    End

    It '途中の引数が空文字列の場合、1を返すこと'
      When call "$1" $'\001' '' $'\037'
      The status should equal 1
    End

    It '最後の引数が空文字列の場合、1を返すこと'
      When call "$1" $'\001' $'\037' ''
      The status should equal 1
    End

    It '先頭にスペースが混在する場合、1を返すこと'
      When call "$1" $'\040\037'
      The status should equal 1
    End

    It '途中にDELが混在する場合、1を返すこと'
      When call "$1" $'\001\177\037'
      The status should equal 1
    End

    It '末尾にC1が混在する場合、1を返すこと'
      When call "$1" $'\001\037\200'
      The status should equal 1
    End

    It '途中の引数が範囲外の場合、1を返すこと'
      When call "$1" $'\001' 'a' $'\037'
      The status should equal 1
    End

    It '長いC0文字列を受理すること'
      long_c0=$'\001\037'
      for step in 1 2 3 4 5 6 7 8 9; do
        long_c0="${long_c0}${long_c0}"
      done
      When call "$1" "${long_c0}"
      The status should equal 0
    End
  End
End
