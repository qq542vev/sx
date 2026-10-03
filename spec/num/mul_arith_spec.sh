#!/bin/sh
# ShellSpecのParameters内の値をコマンドとして解釈する診断を抑制する。
# shellcheck disable=SC2016,SC2215,SC2286

eval "$(shellspec - -c) exit 1"

Describe 'sx_num_mul_arith'
  Include ./sx.sh
  Before 'sx_cfg_set NUM_RANGE=32'

  Context '安全な乗算'
    Parameters
      1
      0 0 -2147483648
      -2147483648 -2147483648 1
      -64 +010 0x4 -2
      9 -3 -3
      2147395600 46340 46340
      -2147395600 -46340 46340
      2147483647 2147483647 1 1
      0 2147483647 1 0 -2147483648
      0 0 2147483647 2
    End

    It "引数列 $* の結果が $1 になること"
      expected="$1"
      shift
      When call sx_num_mul_arith result "$@"
      The status should be success
      The variable result should equal "${expected}"
      The stdout should equal ''
      The stderr should equal ''
    End
  End

  Context '桁溢れ'
    Parameters
      2147483647 2
      -2147483648 -1
      -1 -2147483648
      46341 46341
      -46341 46341
      2147483647 1 2
      2147483647 2 0
      -2147483648 1 -1
      0x7fffffff 02
      -0x80000000 -01
    End

    It "引数列 $* を64で拒否し、結果変数を変更しないこと"
      result=unchanged
      When call sx_num_mul_arith result "$@"
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
      When call sx_num_mul_arith result "$1"
      The status should equal 64
      The variable result should equal unchanged
    End
  End

  It '結果変数の省略を64で拒否すること'
    When call sx_num_mul_arith
    The status should equal 64
  End

  It '読み取り専用の結果変数を77で拒否すること'
    readonly ro_mul_arith=original
    When call sx_num_mul_arith ro_mul_arith 1
    The status should equal 77
    The variable ro_mul_arith should equal original
  End

  Context '不正な設定'
    Parameters
      ''
      invalid
      16
    End

    It "設定 $1 を78で拒否すること"
      SX_CFG_NUM_RANGE="$1"
      When call sx_num_mul_arith result 1
      The status should equal 78
    End
  End

  It 'チェック省略時も安全に乗算できること'
    SX_CFG_SKIP_CHK=1
    When call sx_num_mul_arith result -3 2
    The status should be success
    The variable result should equal -6
  End

  Context '64ビット設定'
    arith_lt64() { ( : $(( 0x7FFFFFFF + 1 )) ) 2>&- || return 0; return 1; }
    Skip if 'ホストの算術展開が64bit未満のため' arith_lt64
    Before 'sx_cfg_set NUM_RANGE=64'

    Parameters
      9223372036854775807 9223372036854775807 1
      -9223372036854775808 -9223372036854775808 1
      9223372030926249001 3037000499 3037000499
      -9223372030926249001 -3037000499 3037000499
    End

    It "引数列 $* の結果が $1 になること"
      expected="$1"
      shift
      When call sx_num_mul_arith result "$@"
      The status should be success
      The variable result should equal "${expected}"
    End
  End
End
