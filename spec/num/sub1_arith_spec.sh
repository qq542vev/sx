#!/bin/sh
# ShellSpecのParameters内の符号付き数値をコマンドとして解釈する診断を抑制する。
# shellcheck disable=SC2215,SC2286,SC2288

eval "$(shellspec - -c) exit 1"

Describe '__sx_num_sub1_arith'
  Include ./sx.sh
  Before 'sx_cfg_set NUM_RANGE=32'

  Context '符号・基数と32ビットの境界値'
    Parameters
      0 -1
      1 0
      42 41
      -1 -2
      -42 -43
      +010 7
      -010 -9
      +0Xf 14
      -0x10 -17
      -00 -1
      +0 -1
      2147483647 2147483646
      -2147483647 -2147483648
      -017777777777 -2147483648
      -0x7fffffff -2147483648
    End

    It "入力 $1 から1を減算して10進表記で格納すること"
      When call __sx_num_sub1_arith result "$1"
      The status should be success
      The variable result should equal "$2"
    End
  End

  It '入力と結果に同じ変数を使えること'
    result=-2147483647
    When call __sx_num_sub1_arith result "$result"
    The status should be success
    The variable result should equal -2147483648
  End

  It 'numという結果変数も保持すること'
    When call __sx_num_sub1_arith num 42
    The status should be success
    The variable num should equal 41
  End

  It '呼び出し元のnumを変更しないこと'
    num=preserved
    When call __sx_num_sub1_arith result 0
    The status should be success
    The variable result should equal -1
    The variable num should equal preserved
  End

  Context '64ビットの境界値'
    Skip if 'ホストの算術展開が64bit未満のため' arith_lt64
    Before 'sx_cfg_set NUM_RANGE=64'

    Parameters
      9223372036854775807 9223372036854775806
      -9223372036854775807 -9223372036854775808
      -0777777777777777777777 -9223372036854775808
      -0x7fffffffffffffff -9223372036854775808
    End

    It "入力 $1 から1を減算すること"
      When call __sx_num_sub1_arith result "$1"
      The status should be success
      The variable result should equal "$2"
    End
  End
End
