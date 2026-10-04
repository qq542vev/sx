#!/bin/sh
# ShellSpecのParameters内の文字列をシェルコードとして解釈する診断を抑制する。
# shellcheck disable=SC2016,SC2286

eval "$(shellspec - -c) exit 1"

Describe 'sx_num_is_sub_arith_safe'
  Include ./sx.sh
  Before 'sx_cfg_set NUM_RANGE=32'

  Context '32ビットの減算可能性'
    Parameters
      0
      0 42
      0 -2147483648
      0 +010 0x3 01
      0 -5 -3
      0 2147483647 1
      0 -2147483648 -1
      0 2147483647 2147483647
      0 -2147483648 -2147483648
      0 1 2147483647 -2147483648
      0 2147483647 1 2147483647 2147483647
      1 2147483647 -1
      1 -2147483648 1
      1 1 0 -2147483648
      1 0 -2147483648 -2147483648
      64 abc
      64 2147483648
      64 2147483647 -1 abc
    End

    It "引数列 $* の減算可能性を判定すること"
      expected="$1"
      shift
      When call sx_num_is_sub_arith_safe "$@"
      The status should equal "${expected}"
      The stdout should equal ''
      The stderr should equal ''
    End
  End

  Context '不正な設定'
    Parameters
      ''
      invalid
      16
    End

    It "設定 $1 を78で拒否すること"
      SX_CFG_NUM_RANGE="$1"
      When call sx_num_is_sub_arith_safe 1
      The status should equal 78
    End
  End

  Context 'チェック省略'
    Before 'sx_cfg_set SKIP_CHK=1'

    It '安全な減算を0で判定すること'
      When call sx_num_is_sub_arith_safe -2147483648 -1
      The status should be success
    End

    It 'チェック省略時も桁溢れを1で判定すること'
      When call sx_num_is_sub_arith_safe 2147483647 -1
      The status should equal 1
    End
  End

  Context '32bit算術シェル専用の算術域境界'
    Skip if '32bit算術シェル専用のため' arith_not32
    Before 'sx_cfg_set NUM_RANGE=32'

    It '0から最小値を引く桁溢れを演算前に判定すること'
      When call sx_num_is_sub_arith_safe 0 -2147483648
      The status should equal 1
      The stdout should equal ''
      The stderr should equal ''
    End
  End

  Context '64ビット設定'
    Skip if 'ホストの算術展開が64bit未満のため' arith_lt64
    Before 'sx_cfg_set NUM_RANGE=64'

    Parameters
      0 9223372036854775807 1
      0 -9223372036854775808 -1
      0 9223372036854775807 9223372036854775807
      0 -9223372036854775808 -9223372036854775808
      1 9223372036854775807 -1
      1 -9223372036854775808 1
      1 0 -9223372036854775808
      64 9223372036854775808
    End

    It "引数列 $* を64ビット幅で判定すること"
      expected="$1"
      shift
      When call sx_num_is_sub_arith_safe "$@"
      The status should equal "${expected}"
      The stdout should equal ''
      The stderr should equal ''
    End
  End
End
