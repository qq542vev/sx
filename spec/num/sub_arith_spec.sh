#!/bin/sh
# ShellSpecのParameters内の文字列をシェルコードとして解釈する診断を抑制する。
# shellcheck disable=SC2016,SC2215,SC2286

eval "$(shellspec - -c) exit 1"

Describe 'sx_num_sub_arith'
  Include ./sx.sh
  Before 'sx_cfg_set NUM_RANGE=32'

  Context '安全な減算'
    Parameters
      0
      42 42
      -7 3 10
      4 +010 0x3 01
      8 5 -3
      -8 -5 3
      0 5 5
      0 2147483647 2147483647
      0 -2147483648 -2147483648
      2147483646 2147483647 1
      -2147483647 -2147483648 -1
      2 1 2147483647 -2147483648
      2147483642 2147483647 2 3
    End

    It "引数列 $* の結果が $1 になること"
      expected="$1"
      shift
      When call sx_num_sub_arith result "$@"
      The status should be success
      The variable result should equal "${expected}"
      The stdout should equal ''
      The stderr should equal ''
    End
  End

  Context '桁溢れ'
    Parameters
      2147483647 -1
      -2147483648 1
      1 0 -2147483648
      0 -2147483648 -2147483648
      017777777777 -01
      -020000000000 01
    End

    It "引数列 $* を64で拒否し、結果変数を変更しないこと"
      result=unchanged
      When call sx_num_sub_arith result "$@"
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
      08
      0xG
      2147483648
    End

    It "入力 $1 を64で拒否すること"
      result=unchanged
      When call sx_num_sub_arith result "$1"
      The status should equal 64
      The variable result should equal unchanged
    End
  End

  It '結果変数の省略を64で拒否すること'
    When call sx_num_sub_arith
    The status should equal 64
  End

  It '読み取り専用の結果変数を77で拒否すること'
    readonly ro_sub_arith=original
    When call sx_num_sub_arith ro_sub_arith 1
    The status should equal 77
    The variable ro_sub_arith should equal original
  End

  Context '不正な設定'
    Parameters
      ''
      invalid
      16
    End

    It "設定 $1 を78で拒否すること"
      SX_CFG_NUM_RANGE="$1"
      When call sx_num_sub_arith result 1
      The status should equal 78
    End
  End

  It 'チェック省略時も安全に減算できること'
    SX_CFG_SKIP_CHK=1
    When call sx_num_sub_arith result -2147483648 -1
    The status should be success
    The variable result should equal -2147483647
  End

  Context '64ビット設定'
    arith_lt64() { ( : $(( 0x7FFFFFFF + 1 )) ) 2>&- || return 0; return 1; }
    Skip if 'ホストの算術展開が64bit未満のため' arith_lt64
    Before 'sx_cfg_set NUM_RANGE=64'

    Parameters
      9223372036854775806 9223372036854775807 1
      -9223372036854775807 -9223372036854775808 -1
      0 9223372036854775807 9223372036854775807
      0 -9223372036854775808 -9223372036854775808
    End

    It "引数列 $* の結果が $1 になること"
      expected="$1"
      shift
      When call sx_num_sub_arith result "$@"
      The status should be success
      The variable result should equal "${expected}"
    End
  End
End
