#!/bin/sh
# shellcheck disable=SC3003 # 制御文字にはPOSIX.1-2024のドル単一引用符を使用する。

eval "$(shellspec - -c) exit 1"

Describe 'sx_str_is_c1 / __sx_str_is_c1'
  sxtest_load ./build/modules/sx_str_is_c1.sh

  Context 'C1領域の全32値'
    Parameters:matrix
      sx_str_is_c1 __sx_str_is_c1
      $'\200' $'\201' $'\202' $'\203' $'\204' $'\205' $'\206' $'\207' $'\210' $'\211' $'\212' $'\213' $'\214' $'\215' $'\216' $'\217' $'\220' $'\221' $'\222' $'\223' $'\224' $'\225' $'\226' $'\227' $'\230' $'\231' $'\232' $'\233' $'\234' $'\235' $'\236' $'\237'
    End

    It '未割当・削除済みの位置も含めて受理すること'
      When call "$1" "$2"
      The status should equal 0
    End
  End

  Context 'C1領域以外の入力'
    Parameters:matrix
      sx_str_is_c1 __sx_str_is_c1
      '' 'a' '0' ' ' '*' '?' '[' ']' '-' '^' '\' $'\001' $'\t' $'\n' $'\037' $'\177' $'\240' $'\377' 'é' '日本語' '😀'
    End

    It '不一致として1を返すこと'
      When call "$1" "$2"
      The status should equal 1
    End
  End

  Context '引数列と境界条件'
    Parameters
      sx_str_is_c1
      __sx_str_is_c1
    End

    It 'C1領域の複数のバイトと複数の引数を受理すること'
      When call "$1" $'\200\237' $'\205\233\234' $'\201\204\231'
      The status should equal 0
    End

    It '引数がない場合、0を返すこと'
      When call "$1"
      The status should equal 0
    End

    It '先頭の引数が空文字列の場合、1を返すこと'
      When call "$1" '' $'\200' $'\237'
      The status should equal 1
    End

    It '途中の引数が空文字列の場合、1を返すこと'
      When call "$1" $'\200' '' $'\237'
      The status should equal 1
    End

    It '最後の引数が空文字列の場合、1を返すこと'
      When call "$1" $'\200' $'\237' ''
      The status should equal 1
    End

    It '先頭に範囲外のバイトが混在する場合、1を返すこと'
      When call "$1" $'\177\200' $'\237'
      The status should equal 1
    End

    It '途中に範囲外のバイトが混在する場合、1を返すこと'
      When call "$1" $'\200\177\237'
      The status should equal 1
    End

    It '末尾に範囲外のバイトが混在する場合、1を返すこと'
      When call "$1" $'\200' $'\237\240'
      The status should equal 1
    End

    It '途中の引数が範囲外の場合、1を返すこと'
      When call "$1" $'\200' 'a' $'\237'
      The status should equal 1
    End

    It '長いC1文字列を受理すること'
      long_c1=$'\200\237'
      for step in 1 2 3 4 5 6 7 8 9; do
        long_c1="${long_c1}${long_c1}"
      done
      When call "$1" "${long_c1}"
      The status should equal 0
    End
  End
End
