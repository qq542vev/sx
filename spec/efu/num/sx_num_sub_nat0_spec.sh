# shellcheck shell=sh
# ShellSpecのParameters内の負数・範囲指定の診断を抑制する。
# shellcheck disable=SC2215,SC2288

Describe 'sx_num_sub_nat0 -efu 環境検証'
  Include ./sx.sh

  sub_check_value() {
    expected="$1"
    shift
    result=old
    sx_num_sub_nat0 result "$@"
    case "$result" in "$expected") ;; *) return 1;; esac
    check_no_leak
  }

  Context '32bit算術シェル専用の算術域境界'
    Skip if '32bit算術シェル専用のため' arith_not32
    Before 'sx_cfg_set NUM_RANGE=32'

    Parameters
      4 2147483648 2147483644
      0 2147483648 2147483648
    End

    It "引数列 $* を-e下で減算して内部変数を解放すること"
      When run efu_run sub_check_value "$@"
      The status should be success
      The stdout should equal ''
      The stderr should equal ''
    End
  End

  It '正常動作'

    When run efu_run sx_num_sub_nat0 result
    The status should be success
  End
End
