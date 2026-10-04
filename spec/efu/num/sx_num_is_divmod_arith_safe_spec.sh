# shellcheck shell=sh
# ShellSpecのParameters内の負数の診断を抑制する。
# shellcheck disable=SC2215

Describe 'sx_num_is_divmod_arith_safe -efu 環境検証'
  Include ./sx.sh
  Before 'sx_cfg_set NUM_RANGE=32'

  Context '除算可能性'
    Parameters
      0
      0 -2147483648 1
      0 -2147483648 -2147483648
      0 +010 -0x3
      1 7 -0x0
      1 -2147483648 -1
      1 -0x80000000 -01
      64 08 2
      64 7 abc
      64 2147483648 1
    End

    It "引数列 $* の安全性を-e下で判定すること"
      expected="$1"
      shift
      When run efu_run sx_num_is_divmod_arith_safe "$@"
      The status should equal "$expected"
      The stdout should equal ''
      The stderr should equal ''
    End
  End

  It '不正な設定を78で拒否すること'
    SX_CFG_NUM_RANGE=invalid
    When run efu_run sx_num_is_divmod_arith_safe 7 2
    The status should equal 78
  End

  Context 'チェック省略'
    Before 'sx_cfg_set SKIP_CHK=1'

    Parameters
      1 7 -0x0
      1 -2147483648 -1
    End

    It "引数列 $* の安全判定を省略しないこと"
      expected="$1"
      shift
      When run efu_run sx_num_is_divmod_arith_safe "$@"
      The status should equal "$expected"
      The stderr should equal ''
    End
  End

  Context '32bit算術シェル専用の算術域境界'
    Skip if '32bit算術シェル専用のため' arith_not32
    Before 'sx_cfg_set NUM_RANGE=32'

    Parameters
      -2147483648 3
      2147483647 -1
    End

    It "引数列 $* の除算可能性を-e下で判定すること"
      When run efu_run sx_num_is_divmod_arith_safe "$@"
      The status should be success
      The stdout should equal ''
      The stderr should equal ''
    End
  End

  Context '64ビット設定'
    Skip if 'ホストの算術展開が64bit未満のため' arith_lt64
    Before 'sx_cfg_set NUM_RANGE=64'

    Parameters
      0 -9223372036854775808 3
      0 9223372036854775807 -1
      1 -9223372036854775808 -1
      1 -0x8000000000000000 -01
      64 9223372036854775808 1
    End

    It "引数列 $* を64ビット幅で判定すること"
      expected="$1"
      shift
      When run efu_run sx_num_is_divmod_arith_safe "$@"
      The status should equal "$expected"
      The stdout should equal ''
      The stderr should equal ''
    End
  End
End
