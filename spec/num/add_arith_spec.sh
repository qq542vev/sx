#!/bin/sh
# ShellSpecのParameters内の値をコマンドとして解釈する診断を抑制する。
# shellcheck disable=SC2016,SC2215,SC2286,SC2288

eval "$(shellspec - -c) exit 1"

Describe 'sx_num_add_arith'
  Include ./sx.sh
  Before 'sx_cfg_set NUM_RANGE=32'

  It '数値省略時は0を格納すること'
    When call sx_num_add_arith result
    The status should be success
    The variable result should equal 0
  End

  It '符号付きの8・10・16進整数を混在させて加算できること'
    When call sx_num_add_arith result +010 20 -0x10 -03 +0Xf
    The status should be success
    The variable result should equal 24
  End

  It '符号付きゼロを10進の0に正規化すること'
    When call sx_num_add_arith result +0 -0 00 -00 +0x0 -0X0
    The status should be success
    The variable result should equal 0
  End

  It '結果変数の古い値が計算に影響しないこと'
    result=100
    When call sx_num_add_arith result -5 3
    The status should be success
    The variable result should equal -2
  End

  It 'intとの動的な切り替えで同じ結果を得られること'
    type=arith
    expected=
    sx_num_add_int expected 10 -20 30
    When call "sx_num_add_${type}" result 10 -20 30
    The status should be success
    The variable result should equal "${expected}"
  End

  Context '32ビットの境界値'
    Parameters
      2147483647 2147483647
      -2147483648 -2147483648
      017777777777 2147483647
      -020000000000 -2147483648
      +0x7fffffff 2147483647
      -0X80000000 -2147483648
    End

    It "境界値 $1 を10進表記で格納すること"
      When call sx_num_add_arith result "$1"
      The status should be success
      The variable result should equal "$2"
    End
  End

  It '最小値を含む加算で符号反転を必要としないこと'
    When call sx_num_add_arith result -020000000000 +0x7fffffff 1
    The status should be success
    The variable result should equal 0
  End

  Context '32ビットの桁溢れ'
    Parameters
      2147483647 1
      -2147483648 -1
      2147483647 1 -1
      -2147483648 -1 1
      017777777777 01
      -0x80000000 -0x1
      -1 -2147483648
    End

    It "引数列 $* の桁溢れを64で拒否し、結果変数を変更しないこと"
      result=unchanged
      When call sx_num_add_arith result "$@"
      The status should equal 64
      The variable result should equal unchanged
      The stderr should equal ''
    End
  End

  Context '不正な入力'
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
      2147483648
      -2147483649
      020000000000
      -020000000001
      0x80000000
      -0x80000001
      123456789012345678901234567890
    End

    It "入力 $1 を拒否し、結果変数を変更しないこと"
      result=unchanged
      When call sx_num_add_arith result 1 "$1"
      The status should equal 64
      The variable result should equal unchanged
    End
  End

  It '結果変数の省略を拒否すること'
    When call sx_num_add_arith
    The status should equal 64
  End

  It '不正な結果変数名を拒否すること'
    When call sx_num_add_arith 'result;other' 1
    The status should equal 64
  End

  It '読み取り専用の結果変数を拒否すること'
    readonly ro_add_arith=original
    When call sx_num_add_arith ro_add_arith 1
    The status should equal 77
    The variable ro_add_arith should equal original
  End

  Context '不正な設定'
    Parameters
      ''
      abc
      16
    End

    It "不正な設定 $1 を拒否すること"
      SX_CFG_NUM_RANGE="$1"
      result=unchanged
      When call sx_num_add_arith result 1
      The status should equal 78
      The variable result should equal unchanged
    End
  End

  It 'チェック省略時も基数の混在を計算できること'
    SX_CFG_SKIP_CHK=1
    When call sx_num_add_arith result 010 -0x10 +20
    The status should be success
    The variable result should equal 12
  End

  It 'チェック省略時は設定の検証も省略すること'
    SX_CFG_SKIP_CHK=1
    SX_CFG_NUM_RANGE=invalid
    When call sx_num_add_arith result 1 2
    The status should be success
    The variable result should equal 3
  End

  Context '64ビット設定'
    Skip if 'ホストの算術展開が64bit未満のため' arith_lt64
    Before 'sx_cfg_set NUM_RANGE=64'

    Context '境界値'
      Parameters
        9223372036854775807 9223372036854775807
        -9223372036854775808 -9223372036854775808
        0777777777777777777777 9223372036854775807
        -01000000000000000000000 -9223372036854775808
        0x7fffffffffffffff 9223372036854775807
        -0X8000000000000000 -9223372036854775808
      End

      It "境界値 $1 を10進表記で格納すること"
        When call sx_num_add_arith result "$1"
        The status should be success
        The variable result should equal "$2"
      End
    End

    It '最小値を含む加算ができること'
      When call sx_num_add_arith result -0x8000000000000000 0x7fffffffffffffff 1
      The status should be success
      The variable result should equal 0
    End

    Context '桁溢れ'
      Parameters
        9223372036854775807 1
        -9223372036854775808 -1
        9223372036854775807 1 -1
        -9223372036854775808 -1 1
      End

      It "引数列 $* の桁溢れを64で拒否し、結果変数を変更しないこと"
        result=unchanged
        When call sx_num_add_arith result "$@"
        The status should equal 64
        The variable result should equal unchanged
        The stderr should equal ''
      End
    End

    Context '範囲外'
      Parameters
        9223372036854775808
        -9223372036854775809
        01000000000000000000000
        -01000000000000000000001
        0x8000000000000000
        -0x8000000000000001
      End

      It "範囲外の入力 $1 を拒否すること"
        When call sx_num_add_arith result "$1"
        The status should equal 64
        The variable result should be undefined
      End
    End
  End
End
