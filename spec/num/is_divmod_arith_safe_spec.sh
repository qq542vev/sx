#!/bin/sh
# ShellSpecのParameters内の値をシェルコードとして解釈する診断を抑制する。
# shellcheck disable=SC2016,SC2286

eval "$(shellspec - -c) exit 1"

Describe 'sx_num_is_divmod_arith_safe'
  Include ./sx.sh
  Before 'sx_cfg_set NUM_RANGE=32'

  Context '除算可能性'
    Parameters
      0
      0 -2147483648
      0 '' ''
      0 '' -2
      0 7 ''
      0 -7 -2
      0 +010 -0x3
      0 -2147483648 1
      0 -2147483648 2
      0 -2147483648 -2147483648
      0 2147483647 -1
      0 -2147483648 2147483647
      0 7 2 ignored
      1 7 0
      1 7 +0
      1 7 -0
      1 7 00
      1 7 -00
      1 7 +0x0
      1 7 -0X0
      1 -2147483648 -1
      1 -0x80000000 -01
      1 -020000000000 -0X1
      64 abc 2
      64 7 abc
      64 08 2
      64 7 08
      64 0xG 2
      64 2147483648 -1
      64 -2147483649 1
      64 1 -2147483649
      64 abc 0
      64 -2147483648 invalid
    End

    It "引数列 $* の安全性を判定すること"
      expected="$1"
      shift
      When call sx_num_is_divmod_arith_safe "$@"
      The status should equal "$expected"
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
      When call sx_num_is_divmod_arith_safe 7 2
      The status should equal 78
    End
  End

  Context 'チェック省略'
    Before 'sx_cfg_set SKIP_CHK=1'

    Parameters
      0 -2147483648 2
      1 7 -0x0
      1 -0x80000000 -01
    End

    It "引数列 $* の安全判定を省略しないこと"
      expected="$1"
      shift
      When call sx_num_is_divmod_arith_safe "$@"
      The status should equal "$expected"
    End
  End

  Context '64ビット設定'
    arith_lt64() { ( : $(( 0x7FFFFFFF + 1 )) ) 2>&- || return 0; return 1; }
    Skip if 'ホストの算術展開が64bit未満のため' arith_lt64
    Before 'sx_cfg_set NUM_RANGE=64'

    Parameters
      0 -9223372036854775808 1
      0 -9223372036854775808 -9223372036854775808
      0 9223372036854775807 -1
      1 -9223372036854775808 -1
      1 -0x8000000000000000 -01
      1 -01000000000000000000000 -0X1
      64 9223372036854775808 1
      64 1 -9223372036854775809
    End

    It "引数列 $* を64ビット幅で判定すること"
      expected="$1"
      shift
      When call sx_num_is_divmod_arith_safe "$@"
      The status should equal "$expected"
      The stderr should equal ''
    End
  End
End
