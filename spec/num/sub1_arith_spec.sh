#!/bin/sh
# shellcheck disable=SC2016 # CMD内の変数は準備用シェルで展開する。
# ShellSpecのParameters内の値をコマンドとして解釈する診断を抑制する。
# shellcheck disable=SC2016,SC2215,SC2286,SC2288

eval "$(shellspec - -c) exit 1"

Describe 'sx_num_sub1_arith'
  Include ./spec/support/run.sh
  Include ./spec/support/library.sh sx_num_sub1_arith
  Before 'sxtest_run SX_CFG_NUM_RANGE SX_SYS_NUM_MAX SX_SYS_NUM_MIN -- "sx_cfg_set NUM_RANGE=32"'

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
      When call sx_num_sub1_arith result "$1"
      The status should be success
      The variable result should equal "$2"
    End
  End

  It '入力と結果に同じ変数を使えること'
    result=-2147483647
    When call sx_num_sub1_arith result "$result"
    The status should be success
    The variable result should equal -2147483648
  End

  It 'numという結果変数も保持すること'
    When call sx_num_sub1_arith num 42
    The status should be success
    The variable num should equal 41
  End

  It '呼び出し元のnumを変更しないこと'
    num=preserved
    When call sx_num_sub1_arith result 0
    The status should be success
    The variable result should equal -1
    The variable num should equal preserved
  End

  Context '不正な入力と桁溢れ'
    Parameters
      ''
      +
      --1
      abc
      1.5
      1+2
      '1;result=999'
      '$(result=999)'
      08
      0x
      0xG
      -2147483648
      -020000000000
      -0x80000000
      2147483648
      -2147483649
      123456789012345678901234567890
    End

    It "入力 $1 を64で拒否し、結果変数を変更しないこと"
      result=unchanged
      When call sx_num_sub1_arith result "$1"
      The status should equal 64
      The variable result should equal unchanged
      The stderr should equal ''
    End
  End

  It '引数の省略を拒否すること'
    When call sx_num_sub1_arith
    The status should equal 64
  End

  It '数値の省略を拒否すること'
    result=unchanged
    When call sx_num_sub1_arith result
    The status should equal 64
    The variable result should equal unchanged
  End

  It '不正な結果変数名を拒否すること'
    When call sx_num_sub1_arith 'result;other' 1
    The status should equal 64
  End

  It '読み取り専用の結果変数を拒否すること'
    readonly ro_sub1_arith=original
    When call sx_num_sub1_arith ro_sub1_arith 1
    The status should equal 77
    The variable ro_sub1_arith should equal original
  End

  It '不正な設定を拒否して結果変数を変更しないこと'
    SX_CFG_NUM_RANGE=invalid
    result=unchanged
    When call sx_num_sub1_arith result 1
    The status should equal 78
    The variable result should equal unchanged
  End

  It 'チェック省略時は設定検証も省略して減算すること'
    SX_CFG_SKIP_CHK=1
    SX_CFG_NUM_RANGE=invalid
    When call sx_num_sub1_arith result -0x10
    The status should be success
    The variable result should equal -17
  End

  Context '64ビット設定'
    Skip if 'ホストの算術展開が64bit未満のため' arith_lt64
    Before 'sxtest_run SX_CFG_NUM_RANGE SX_SYS_NUM_MAX SX_SYS_NUM_MIN -- "sx_cfg_set NUM_RANGE=64"'

    Context '境界値'
      Parameters
        9223372036854775807 9223372036854775806
        -9223372036854775807 -9223372036854775808
        -0777777777777777777777 -9223372036854775808
        -0x7fffffffffffffff -9223372036854775808
      End

      It "入力 $1 から1を減算すること"
        When call sx_num_sub1_arith result "$1"
        The status should be success
        The variable result should equal "$2"
      End
    End

    Context '最小値からの減算'
      Parameters
        -9223372036854775808
        -01000000000000000000000
        -0x8000000000000000
      End

      It "入力 $1 の桁溢れを減算前に拒否すること"
        result=unchanged
        When call sx_num_sub1_arith result "$1"
        The status should equal 64
        The variable result should equal unchanged
        The stderr should equal ''
      End
    End
  End
End

Describe '__sx_num_sub1_arith'
  Include ./spec/support/run.sh
  Include ./spec/support/library.sh __sx_num_sub1_arith
  Before 'sxtest_run SX_CFG_NUM_RANGE -- "sx_cfg_set NUM_RANGE=32"'

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
    Before 'sxtest_run SX_CFG_NUM_RANGE -- "sx_cfg_set NUM_RANGE=64"'

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
