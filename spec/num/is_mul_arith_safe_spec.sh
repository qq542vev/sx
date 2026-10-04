#!/bin/sh
# ShellSpecのParameters内の文字列をシェルコードとして解釈する診断を抑制する。
# shellcheck disable=SC2016,SC2286

eval "$(shellspec - -c) exit 1"

Describe 'sx_num_is_mul_arith_safe'
  Include ./sx.sh
  Before 'sx_cfg_set NUM_RANGE=32'

  Context '32ビットの乗算可能性'
    Parameters
      0
      0 1
      0 0 -2147483648
      0 -2147483648
      0 +010 0x4 -2
      0 -3 -3
      0 46340 46340
      0 -46340 46340
      0 2147483647 1 1
      0 2147483647 1 0 -2147483648
      1 2147483647 2
      1 -2147483648 -1
      1 -1 -2147483648
      1 46341 46341
      1 -46341 46341
      1 2147483647 1 2
      1 2147483647 2 0
      1 -2147483648 1 -1
      64 abc
      64 2147483648
      64 2147483647 2 abc
    End

    It "引数列 $* の乗算可能性を判定すること"
      expected="$1"
      shift
      When call sx_num_is_mul_arith_safe "$@"
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
      When call sx_num_is_mul_arith_safe 1
      The status should equal 78
    End
  End

  Context 'チェック省略'
    Before 'sx_cfg_set SKIP_CHK=1'

    It '安全な乗算を0で判定すること'
      When call sx_num_is_mul_arith_safe 0 2147483647 2
      The status should be success
    End

    It 'チェック省略時も桁溢れを1で判定すること'
      When call sx_num_is_mul_arith_safe 2147483647 2
      The status should equal 1
    End
  End

  Context '64ビット設定'
    Skip if 'ホストの算術展開が64bit未満のため' arith_lt64
    Before 'sx_cfg_set NUM_RANGE=64'

    Parameters
      0 -9223372036854775808 1
      0 -3037000499 3037000499
      0 0 9223372036854775807
      1 9223372036854775807 2
      1 -9223372036854775808 -1
      1 -1 -9223372036854775808
      1 3037000500 3037000500
      0 9223372036854775807 1 0
      64 9223372036854775808
    End

    It "引数列 $* を64ビット幅で判定すること"
      expected="$1"
      shift
      When call sx_num_is_mul_arith_safe "$@"
      The status should equal "${expected}"
      The stdout should equal ''
      The stderr should equal ''
    End
  End
End
