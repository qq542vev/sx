#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_num_range'
  Include ./sx.sh

  # ホストの算術展開が 64bit 未満か判定する（32bit ホストでは 2^31 超の演算が致命的 overflow になるため）
  arith_lt64() { ( : $(( 0x7FFFFFFF + 1 )) ) 2>&- || return 0; return 1; }

  It '0からN-1までの範囲を生成すること (Python方式: range(stop))'
    When call sx_num_range result 5
    The status should be success
    The variable result should equal "0 1 2 3 4"
  End

  It '開始と終了(exclusive)を指定して範囲を生成すること (Python方式: range(start, stop))'
    When call sx_num_range result 2 5
    The status should be success
    The variable result should equal "2 3 4"
  End

  It '開始、終了(exclusive)、増分を指定して範囲を生成すること (Python方式: range(start, stop, step))'
    When call sx_num_range result 1 5 2
    The status should be success
    The variable result should equal "1 3"
  End

  It '負の増分で逆順の範囲を生成すること (Python方式: range(start, stop, step))'
    When call sx_num_range result 5 1 -1
    The status should be success
    The variable result should equal "5 4 3 2"
  End

  It '増分が0の場合は EX_USAGE を返すこと'
    When call sx_num_range result 1 5 0
    The status should equal 64
  End

  It '範囲外の場合は空文字を返すこと (増分正)'
    When call sx_num_range result 5 2
    The status should be success
    The variable result should equal ""
  End

  It '範囲外の場合は空文字を返すこと (増分負)'
    When call sx_num_range result 1 5 -1
    The status should be success
    The variable result should equal ""
  End

  It '引数が不正な場合に EX_USAGE を返すこと'
    When call sx_num_range result
    The status should equal 64
  End

  It '数値が不正な場合に EX_USAGE を返すこと'
    When call sx_num_range result "a"
    The status should equal 64
  End

  It '読み取り専用変数の場合に EX_NOPERM を返すこと'
    readonly ro_var=1
    When call sx_num_range ro_var 5
    The status should equal 77
  End

  Describe 'bind機能'
    It '複数の変数に分配代入すること'
      When call sx_num_range i:j:k 1 4
      The status should be success
      The variable i should equal 1
      The variable j should equal 2
      The variable k should equal 3
    End

    It '残りの要素を最後の変数に集約すること'
      When call sx_num_range i:j 1 5
      The status should be success
      The variable i should equal 1
      The variable j should equal "2 3 4"
    End

    It '指定された変数分だけ取得して停止すること'
      When call sx_num_range i:j: 1 10
      The status should be success
      The variable i should equal 1
      The variable j should equal 2
    End

    It '空のセグメントで要素をスキップすること'
      When call sx_num_range i::k 1 4
      The status should be success
      The variable i should equal 1
      The variable k should equal 3
    End

    It '負の増分でも分配代入ができること'
      When call sx_num_range i:j:k: 5 1 -1
      The status should be success
      The variable i should equal 5
      The variable j should equal 4
      The variable k should equal 3
    End
  End

  Context '64ビット設定'
    Before 'sx_cfg_set NUM_RANGE=64'
    Skip if 'ホストの算術展開が64bit未満のため' arith_lt64

    It 'INT64_MINを開始値とする範囲の先頭2要素を取得すること'
      When call sx_num_range "i:j:" "-9223372036854775808" "9223372036854775807" 1
      The status should be success
      The variable i should equal "-9223372036854775808"
      The variable j should equal "-9223372036854775807"
    End

    It '64bit全域spanの範囲の先頭2要素を取得すること'
      When call sx_num_range "i:j:" "-9223372036854775807" "9223372036854775807" 1
      The status should be success
      The variable i should equal "-9223372036854775807"
      The variable j should equal "-9223372036854775806"
    End

    It '終了値がINT64_MINの逆順範囲の先頭2要素を取得すること'
      When call sx_num_range "i:j:" "5" "-9223372036854775808" -1
      The status should be success
      The variable i should equal "5"
      The variable j should equal "4"
    End

    It '増分がINT64_MINの範囲を取得すること (要素1件)'
      When call sx_num_range r 5 0 -9223372036854775808
      The status should be success
      The variable r should equal "5"
    End

    It '増分がINT64_MINの範囲を取得すること (要素2件)'
      When call sx_num_range r 5 -9223372036854775808 -9223372036854775808
      The status should be success
      The variable r should equal "5 -9223372036854775803"
    End
  End
End
