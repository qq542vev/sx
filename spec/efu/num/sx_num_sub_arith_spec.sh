# shellcheck shell=sh
# ShellSpecのParameters内の負数をコマンドとして解釈する診断を抑制する。
# shellcheck disable=SC2215

Describe 'sx_num_sub_arith -efu 環境検証'
  Include ./sx.sh
  Before 'sx_cfg_set NUM_RANGE=32'

  Context '32ビットの減算'
    Parameters
      0
      -7 3 10
      4 +010 0x3 01
      0 2147483647 2147483647
      -2147483647 -2147483648 -1
      64 2147483647 -1
      64 -2147483648 1
      64 08
    End

    It "引数列 $* の終了ステータスを返すこと"
      case "$1" in 64) expected=64;; *) expected=0;; esac
      shift
      When run efu_run sx_num_sub_arith result "$@"
      The status should equal "$expected"
      The stderr should equal ''
    End
  End

  It 'チェック省略時も減算できること'
    SX_CFG_SKIP_CHK=1
    When run efu_run sx_num_sub_arith result -5 3
    The status should be success
  End

  Context '64ビット設定'
    Skip if 'ホストの算術展開が64bit未満のため' arith_lt64
    Before 'sx_cfg_set NUM_RANGE=64'

    Parameters
      0 9223372036854775807 9223372036854775807
      -9223372036854775807 -9223372036854775808 -1
      64 9223372036854775807 -1
      64 -9223372036854775808 1
    End

    It "引数列 $* の終了ステータスを返すこと"
      case "$1" in 64) expected=64;; *) expected=0;; esac
      shift
      When run efu_run sx_num_sub_arith result "$@"
      The status should equal "$expected"
      The stderr should equal ''
    End
  End
End
