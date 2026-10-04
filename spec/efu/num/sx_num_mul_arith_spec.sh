# shellcheck shell=sh
# ShellSpecのParameters内の負数をコマンドとして解釈する診断を抑制する。
# shellcheck disable=SC2215

Describe 'sx_num_mul_arith -efu 環境検証'
  Include ./sx.sh
  Before 'sx_cfg_set NUM_RANGE=32'

  Context '32ビットの乗算'
    Parameters
      1
      0 0 -2147483648
      -2147483648 -2147483648 1
      -64 +010 0x4 -2
      2147395600 46340 46340
      64 2147483647 2
      64 -2147483648 -1
      64 -1 -2147483648
      64 2147483647 2 0
      64 0x80000000
    End

    It "引数列 $* の終了ステータスを返すこと"
      case "$1" in 64) expected=64;; *) expected=0;; esac
      shift
      When run efu_run sx_num_mul_arith result "$@"
      The status should equal "$expected"
      The stderr should equal ''
    End
  End

  It 'チェック省略時も乗算できること'
    SX_CFG_SKIP_CHK=1
    When run efu_run sx_num_mul_arith result -3 2
    The status should be success
  End

  mul_boundary_check_value() {
    result=old
    sx_num_mul_arith result -46340 46340
    case "$result" in -2147395600) ;; *) return 1;; esac
    check_no_leak
  }

  Context '32bit算術シェル専用の算術域境界'
    Skip if '32bit算術シェル専用のため' arith_not32
    Before 'sx_cfg_set NUM_RANGE=32'

    It '負数を含む最大値付近の積と内部変数の解放を-e下で検証すること'
      When run efu_run mul_boundary_check_value
      The status should be success
      The stdout should equal ''
      The stderr should equal ''
    End
  End

  Context '64ビット設定'
    Skip if 'ホストの算術展開が64bit未満のため' arith_lt64
    Before 'sx_cfg_set NUM_RANGE=64'

    Parameters
      -9223372036854775808 -9223372036854775808 1
      -9223372030926249001 -3037000499 3037000499
      64 9223372036854775807 2
      64 -9223372036854775808 -1
      64 -1 -9223372036854775808
      9223372036854775807 1 0
    End

    It "引数列 $* の終了ステータスを返すこと"
      case "$1" in 64) expected=64;; *) expected=0;; esac
      shift
      When run efu_run sx_num_mul_arith result "$@"
      The status should equal "$expected"
      The stderr should equal ''
    End
  End
End
