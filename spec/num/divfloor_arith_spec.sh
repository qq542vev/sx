#!/bin/sh
# ShellSpecのParameters内の値をシェルコードとして解釈する診断を抑制する。
# shellcheck disable=SC2016,SC2215,SC2286

eval "$(shellspec - -c) exit 1"

Describe 'sx_num_divfloor_arith'
  Include ./sx.sh
  Before 'sx_cfg_set NUM_RANGE=32'

  Context '切り捨て商'
    Parameters
      0
      42 42
      0 '' ''
      7 7 ''
      0 '' -2
      3 7 2
      -4 -7 2
      -4 7 -2
      3 -7 -2
      3 6 2
      -3 -6 2
      -3 6 -2
      3 -6 -2
      0 1 2
      -1 -1 2
      -1 1 -2
      0 -1 -2
      0 -0 3
      0 +0x0 -01
      2 +010 0x3
      -3 -010 +0X3
      -3 +010 -0x3
      2 -010 -0X3
      3 7 2 ignored
      -2147483648 -2147483648 1
      2147483647 2147483647 1
      -2147483647 2147483647 -1
      -1073741824 -2147483648 2
      -715827883 -2147483648 3
      715827882 -2147483648 -3
      1 -2147483648 -2147483648
      -2 -2147483648 2147483647
      -1 2147483647 -2147483648
      -1 1 -2147483648
      0 -1 -2147483648
      -1073741824 -0x80000000 02
    End

    It "引数列 $* の商が $1 になること"
      expected="$1"
      shift
      result=old
      When call sx_num_divfloor_arith result "$@"
      The status should be success
      The variable result should equal "$expected"
      The stdout should equal ''
      The stderr should equal ''
    End
  End

  Context 'ゼロ除算と商の桁溢れ'
    Parameters
      7 0
      7 +0
      7 -0
      7 00
      7 +0x0
      7 -0X0
      -2147483648 -1
      -0x80000000 -01
      -020000000000 -0X1
    End

    It "引数列 $* を64で拒否して結果を変更しないこと"
      result=old
      When call sx_num_divfloor_arith result "$@"
      The status should equal 64
      The variable result should equal old
      The stdout should equal ''
      The stderr should equal ''
    End
  End

  Context '形式不正と入力範囲外'
    Parameters
      abc
      +
      --1
      1.5
      08
      0xG
      2147483648
      -2147483649
      0x80000000
      -020000000001
    End

    It "被除数 $1 を64で拒否すること"
      result=old
      When call sx_num_divfloor_arith result "$1" 2
      The status should equal 64
      The variable result should equal old
      The stderr should equal ''
    End

    It "除数 $1 を64で拒否すること"
      result=old
      When call sx_num_divfloor_arith result 7 "$1"
      The status should equal 64
      The variable result should equal old
      The stderr should equal ''
    End
  End

  It '結果変数の省略を64で拒否すること'
    When call sx_num_divfloor_arith
    The status should equal 64
  End

  It '単一変数名以外を64で拒否すること'
    When call sx_num_divfloor_arith 'q:r:' 7 2
    The status should equal 64
  End

  It 'readonly変数を77で拒否すること'
    readonly ro_divfloor_arith=old
    When call sx_num_divfloor_arith ro_divfloor_arith 7 2
    The status should equal 77
    The variable ro_divfloor_arith should equal old
  End

  Context 'intとの切替互換性'
    Parameters
      7 2
      -7 2
      7 -2
      -7 -2
      -2147483648 3
      -2147483648 2147483647
      1 -2147483648
    End

    It "引数列 $* の商がintと一致すること"
      expected=
      sx_num_divfloor_int expected "$@"
      type=arith
      When call "sx_num_divfloor_$type" result "$@"
      The status should be success
      The variable result should equal "$expected"
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
      result=old
      When call sx_num_divfloor_arith result 7 2
      The status should equal 78
      The variable result should equal old
    End
  End

  It 'チェック省略時は除算安全判定を呼ばないこと'
    SX_CFG_SKIP_CHK=1
    __sx_num_is_divmod_arith_safe() { return 1; }
    When call sx_num_divfloor_arith result -010 0x3
    The status should be success
    The variable result should equal -3
  End

  Context '64ビット設定'
    arith_lt64() { ( : $(( 0x7FFFFFFF + 1 )) ) 2>&- || return 0; return 1; }
    Skip if 'ホストの算術展開が64bit未満のため' arith_lt64
    Before 'sx_cfg_set NUM_RANGE=64'

    Context '境界値の商'
      Parameters
        -9223372036854775808 -9223372036854775808 1
        9223372036854775807 9223372036854775807 1
        -9223372036854775807 9223372036854775807 -1
        -3074457345618258603 -9223372036854775808 3
        3074457345618258602 -9223372036854775808 -3
        -2 -9223372036854775808 9223372036854775807
        -1 9223372036854775807 -9223372036854775808
        -1 1 -0x8000000000000000
        0 -1 -9223372036854775808
        1 -9223372036854775808 -9223372036854775808
      End

      It "引数列 $* の商が $1 になること"
        expected="$1"
        shift
        When call sx_num_divfloor_arith result "$@"
        The status should be success
        The variable result should equal "$expected"
        The stderr should equal ''
      End
    End

    Context '不正な除算'
      Parameters
        -9223372036854775808 -1
        -0x8000000000000000 -01
        9223372036854775808 1
        1 -9223372036854775809
      End

      It "引数列 $* を64で拒否すること"
        result=old
        When call sx_num_divfloor_arith result "$@"
        The status should equal 64
        The variable result should equal old
        The stderr should equal ''
      End
    End
  End
End
