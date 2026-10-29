#!/bin/sh
# shellcheck disable=SC3003 # 高位バイト・制御文字にはPOSIX.1-2024のドル単一引用符を使用する。

eval "$(shellspec - -c) exit 1"

Describe 'sx_str_is_printable / __sx_str_is_printable'
  sxtest_load ./build/modules/sx_str_is_printable.sh

  Context 'ASCII印字領域とGR領域'
    Parameters:matrix
      sx_str_is_printable __sx_str_is_printable
      $'\040\041\042\043\044\045\046\047\050\051\052\053\054\055\056\057\060\061\062\063\064\065\066\067\070\071\072\073\074\075\076\077\100\101\102\103\104\105\106\107\110\111\112\113\114\115\116\117\120\121\122\123\124\125\126\127\130\131\132\133\134\135\136\137\140\141\142\143\144\145\146\147\150\151\152\153\154\155\156\157\160\161\162\163\164\165\166\167\170\171\172\173\174\175\176' $'\240\241\242\243\244\245\246\247\250\251\252\253\254\255\256\257\260\261\262\263\264\265\266\267\270\271\272\273\274\275\276\277\300\301\302\303\304\305\306\307\310\311\312\313\314\315\316\317\320\321\322\323\324\325\326\327\330\331\332\333\334\335\336\337\340\341\342\343\344\345\346\347\350\351\352\353\354\355\356\357\360\361\362\363\364\365\366\367\370\371\372\373\374\375\376\377' $' \240~\377' ''\''' '\' '$' '`' '*' '?' '[' ']' '-' '^' '\xA0' '$(exit 99)' 'aZ09~'
    End

    It '両領域の全191値と引用・パターンに関係する文字を受理すること'
      When call "$1" "$2"
      The status should equal 0
    End
  End

  Context '空文字列とC0・C1・DEL'
    Parameters:matrix
      sx_str_is_printable __sx_str_is_printable
      '' $'\001' $'\002' $'\003' $'\004' $'\005' $'\006' $'\007' $'\010' $'\011' $'\012' $'\013' $'\014' $'\015' $'\016' $'\017' $'\020' $'\021' $'\022' $'\023' $'\024' $'\025' $'\026' $'\027' $'\030' $'\031' $'\032' $'\033' $'\034' $'\035' $'\036' $'\037' $'\177' $'\200' $'\201' $'\202' $'\203' $'\204' $'\205' $'\206' $'\207' $'\210' $'\211' $'\212' $'\213' $'\214' $'\215' $'\216' $'\217' $'\220' $'\221' $'\222' $'\223' $'\224' $'\225' $'\226' $'\227' $'\230' $'\231' $'\232' $'\233' $'\234' $'\235' $'\236' $'\237'
    End

    It '不一致として1を返すこと'
      When call "$1" "$2"
      The status should equal 1
    End
  End

  Context '引数列と境界条件'
    Parameters
      sx_str_is_printable
      __sx_str_is_printable
    End

    It 'ASCIIとGRが混在する複数の引数を受理すること'
      When call "$1" $' \240' $'~\377' "a'\\$"
      The status should equal 0
    End

    It '引数がない場合、0を返すこと'
      When call "$1"
      The status should equal 0
    End

    It '先頭の引数が空文字列の場合、1を返すこと'
      When call "$1" '' 'a' $'\240'
      The status should equal 1
    End

    It '途中の引数が空文字列の場合、1を返すこと'
      When call "$1" 'a' '' $'\377'
      The status should equal 1
    End

    It '最後の引数が空文字列の場合、1を返すこと'
      When call "$1" 'a' $'\377' ''
      The status should equal 1
    End

    It '先頭にC0が混在する場合、1を返すこと'
      When call "$1" $'\037 \240'
      The status should equal 1
    End

    It '途中にDELが混在する場合、1を返すこと'
      When call "$1" $'~\177\240'
      The status should equal 1
    End

    It '末尾にC1が混在する場合、1を返すこと'
      When call "$1" $' \377\237'
      The status should equal 1
    End

    It '途中の引数が制御文字の場合、1を返すこと'
      When call "$1" 'a' $'\200' $'\377'
      The status should equal 1
    End

    It '長いASCIIとGRの混在文字列を受理すること'
      long_printable=$' \240~\377'
      for step in 1 2 3 4 5 6 7 8; do
        long_printable="${long_printable}${long_printable}"
      done
      When call "$1" "${long_printable}"
      The status should equal 0
    End
  End
End
