#!/bin/sh
# ShellSpecのParameters内の文字列をシェルコードとして解釈する診断を抑制する。
# shellcheck disable=SC2016,SC2286

eval "$(shellspec - -c) exit 1"

Describe 'sx_num_is_add_arith_safe'
  Include ./sx.sh
  Before 'sx_cfg_set NUM_RANGE=32'

  Context '32ビットの加算可能性'
    Parameters
      0
      0 0 +0 -0 00 -00 0x0 -0X0
      0 1 -2 3
      0 -5 -3
      0 +010 20 -0x10 -03 +0Xf
      0 2147483647 0
      0 -2147483648 0
      0 017777777777
      0 -020000000000
      0 +0x7fffffff
      0 -0X80000000
      0 2147483646 1
      0 -2147483647 -1
      0 2147483647 -1 1
      0 -2147483648 1 -1
      0 -2147483648 2147483647 1
      0 2147483647 -2147483648 -1
      0 -2147483648 0x7fffffff 1 -020000000000
      1 2147483647 1
      1 -2147483648 -1
      1 2147483647 1 -1
      1 -2147483648 -1 1
      1 2147483647 2147483647
      1 -2147483648 -2147483648
      1 017777777777 +01
      1 -020000000000 -0x1
      1 +0X7fffffff 1
      1 -0x80000000 -1
      1 -1 -020000000000
      1 2147483647 -2147483648 -2147483648
    End

    It "引数列 $* の加算可能性を判定すること"
      expected="$1"
      shift
      When call sx_num_is_add_arith_safe "$@"
      The status should equal "${expected}"
      The stdout should equal ''
      The stderr should equal ''
    End
  End

  Context '不正な入力'
    Parameters
      64 ''
      64 +
      64 --1
      64 abc
      64 1.5
      64 1+2
      64 '1;result=999'
      64 '$(result=999)'
      64 08
      64 0x
      64 0xG
      64 2147483648
      64 -2147483649
      64 020000000000
      64 -020000000001
      64 0x80000000
      64 -0x80000001
      64 123456789012345678901234567890
      64 2147483647 1 abc
    End

    It "入力 $* を計算前に64で拒否すること"
      expected="$1"
      shift
      result=unchanged
      When call sx_num_is_add_arith_safe "$@"
      The status should equal "${expected}"
      The variable result should equal unchanged
      The stdout should equal ''
      The stderr should equal ''
    End
  End

  Context '不正な設定'
    Parameters
      ''
      abc
      16
    End

    It "設定 $1 を78で拒否すること"
      SX_CFG_NUM_RANGE="$1"
      When call sx_num_is_add_arith_safe 1
      The status should equal 78
    End
  End

  Context 'チェック省略'
    Before 'sx_cfg_set SKIP_CHK=1'

    It '安全な加算を0で判定すること'
      When call sx_num_is_add_arith_safe 010 -0x10 +20
      The status should be success
    End

    It 'チェック省略時も桁溢れを1で判定すること'
      When call sx_num_is_add_arith_safe 2147483647 1 -1
      The status should equal 1
    End

    It 'チェック省略時も最小値を扱えること'
      When call sx_num_is_add_arith_safe -2147483648 2147483647 1
      The status should be success
    End
  End

  Context '内部関数'
    It '安全な加算を0で判定すること'
      When call __sx_num_is_add_arith_safe 2147483647 -2147483648
      The status should be success
    End

    It '桁溢れを1で判定すること'
      When call __sx_num_is_add_arith_safe -1 -2147483648
      The status should equal 1
    End
  End

  Context '64ビット設定'
    arith_lt64() { ( : $(( 0x7FFFFFFF + 1 )) ) 2>&- || return 0; return 1; }
    Skip if 'ホストの算術展開が64bit未満のため' arith_lt64
    Before 'sx_cfg_set NUM_RANGE=64'

    Parameters
      0 9223372036854775807 0
      0 -9223372036854775808 0
      0 +0777777777777777777777
      0 -01000000000000000000000
      0 +0x7fffffffffffffff
      0 -0X8000000000000000
      0 9223372036854775806 1
      0 -9223372036854775807 -1
      0 -9223372036854775808 0x7fffffffffffffff 1
      0 9223372036854775807 -0x8000000000000000 -1
      1 9223372036854775807 1
      1 -9223372036854775808 -1
      1 9223372036854775807 1 -1
      1 -9223372036854775808 -1 1
      1 9223372036854775807 9223372036854775807
      1 -9223372036854775808 -9223372036854775808
      1 +0777777777777777777777 01
      1 -01000000000000000000000 -01
      1 +0x7fffffffffffffff 1
      1 -0X8000000000000000 -1
      1 -1 -0x8000000000000000
      64 9223372036854775808
      64 -9223372036854775809
      64 01000000000000000000000
      64 -01000000000000000000001
      64 0x8000000000000000
      64 -0x8000000000000001
    End

    It "引数列 $* を64ビット幅で判定すること"
      expected="$1"
      shift
      When call sx_num_is_add_arith_safe "$@"
      The status should equal "${expected}"
      The stdout should equal ''
      The stderr should equal ''
    End
  End
End
