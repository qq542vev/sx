#!/bin/sh
# ShellSpecのParameters内の値をコマンドとして解釈する診断を抑制する。
# shellcheck disable=SC2016,SC2215,SC2286,SC2288

eval "$(shellspec - -c) exit 1"

Describe 'sx_num_add1_arith'
  Include ./spec/support/prepare.sh
  Include ./spec/support/library.sh sx_num_add1_arith
  Before 'sx_test_setup sx_cfg_set NUM_RANGE=32'

  Context '符号・基数と32ビットの境界値'
    Parameters
      0 1
      42 43
      -1 0
      -42 -41
      +010 9
      -010 -7
      +0Xf 16
      -0x10 -15
      -00 1
      2147483646 2147483647
      -2147483648 -2147483647
      -020000000000 -2147483647
      -0x80000000 -2147483647
    End

    It "入力 $1 に1を加算して10進表記で格納すること"
      When call sx_num_add1_arith result "$1"
      The status should be success
      The variable result should equal "$2"
    End
  End

  It '入力と結果に同じ変数を使えること'
    result=-1
    When call sx_num_add1_arith result "$result"
    The status should be success
    The variable result should equal 0
  End

  It 'numという結果変数も保持すること'
    When call sx_num_add1_arith num 41
    The status should be success
    The variable num should equal 42
  End

  It '呼び出し元のnumを変更しないこと'
    num=preserved
    When call sx_num_add1_arith result -1
    The status should be success
    The variable result should equal 0
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
      2147483647
      017777777777
      +0x7fffffff
      2147483648
      -2147483649
      123456789012345678901234567890
    End

    It "入力 $1 を64で拒否し、結果変数を変更しないこと"
      result=unchanged
      When call sx_num_add1_arith result "$1"
      The status should equal 64
      The variable result should equal unchanged
      The stderr should equal ''
    End
  End

  It '引数の省略を拒否すること'
    When call sx_num_add1_arith
    The status should equal 64
  End

  It '数値の省略を拒否すること'
    When call sx_num_add1_arith result
    The status should equal 64
  End

  It '不正な結果変数名を拒否すること'
    When call sx_num_add1_arith 'result;other' 1
    The status should equal 64
  End

  It '読み取り専用の結果変数を拒否すること'
    readonly ro_add1_arith=original
    When call sx_num_add1_arith ro_add1_arith 1
    The status should equal 77
    The variable ro_add1_arith should equal original
  End

  It '不正な設定を拒否して結果変数を変更しないこと'
    SX_CFG_NUM_RANGE=invalid
    result=unchanged
    When call sx_num_add1_arith result 1
    The status should equal 78
    The variable result should equal unchanged
  End

  It 'チェック省略時は設定検証も省略して加算すること'
    SX_CFG_SKIP_CHK=1
    SX_CFG_NUM_RANGE=invalid
    When call sx_num_add1_arith result -0x10
    The status should be success
    The variable result should equal -15
  End

  Context '64ビット設定'
    Skip if 'ホストの算術展開が64bit未満のため' arith_lt64
    Before 'sx_test_setup sx_cfg_set NUM_RANGE=64'

    Context '境界値'
      Parameters
        -9223372036854775808 -9223372036854775807
        -01000000000000000000000 -9223372036854775807
        -0x8000000000000000 -9223372036854775807
        9223372036854775806 9223372036854775807
      End

      It "入力 $1 に1を加算すること"
        When call sx_num_add1_arith result "$1"
        The status should be success
        The variable result should equal "$2"
      End
    End

    Context '最大値への加算'
      Parameters
        9223372036854775807
        0777777777777777777777
        +0X7fffffffffffffff
      End

      It "入力 $1 の桁溢れを加算前に拒否すること"
        result=unchanged
        When call sx_num_add1_arith result "$1"
        The status should equal 64
        The variable result should equal unchanged
        The stderr should equal ''
      End
    End
  End
End
