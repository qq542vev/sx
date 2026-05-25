#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_num_range'
  Include ./sx.sh

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
End
