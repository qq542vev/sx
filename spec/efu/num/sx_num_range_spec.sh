# shellcheck disable=SC2016 # CMD内の変数は準備用シェルで展開する。
# shellcheck shell=sh
# ShellSpecのParameters内の負数・範囲指定の診断を抑制する。
# shellcheck disable=SC2215,SC2288

Describe 'sx_num_range -efu 環境検証'
  Include ./spec/support/setup.sh
  Include ./spec/support/library.sh sx_num_range

  range_check_values() {
    expected="$1"
    shift
    i='' j='' r=''
    sx_num_range "$@"
    case "${i}:${j}:${r}" in "$expected") ;; *) return 1;; esac
    check_no_leak
  }

  Context '32bit算術シェル専用の算術域境界'
    Skip if '32bit算術シェル専用のため' arith_not32
    Before 'sxtest_setup SX_CFG_NUM_RANGE SX_SYS_NUM_WLEN SX_SYS_NUM_QM SX_SYS_NUM_ZR SX_SYS_NUM_MIN -- "sx_cfg_set NUM_RANGE=32"'

    Parameters
      '-2147483648:-2147483647:' 'i:j:' -2147483648 2147483647 1
      '-2147483647:-2147483646:' 'i:j:' -2147483647 2147483647 1
      '5:4:' 'i:j:' 5 -2147483648 -1
      '::5' r 5 0 -2147483648
      '::5 -2147483643' r 5 -2147483648 -2147483648
    End

    It "引数列 $* の境界値と内部変数の解放を-e下で検証すること"
      When run efu_run range_check_values "$@"
      The status should be success
      The stdout should equal ''
      The stderr should equal ''
    End
  End

  It '正常動作'

    When run efu_run sx_num_range result 5
    The status should be success
  End
End
