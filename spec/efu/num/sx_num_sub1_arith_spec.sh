# shellcheck shell=sh
# ShellSpecのParameters内の負数をコマンドとして解釈する診断を抑制する。
# shellcheck disable=SC2215

Describe '__sx_num_sub1_arith -efu 環境検証'
  Include ./sx.sh
  Before 'sx_cfg_set NUM_RANGE=32'

  sub1_check_value() {
    result=unchanged
    __sx_num_sub1_arith result "$1" || return
    case "$result" in "$2") ;; *) return 1;; esac
    check_no_leak
  }

  It '符号付き16進整数から1を減算すること'
    When run efu_run sub1_check_value -0x10 -17
    The status should be success
    The stdout should equal ''
    The stderr should equal ''
  End

  Context '32bit算術シェル専用の算術域境界'
    Skip if '32bit算術シェル専用のため' arith_not32

    Parameters
      -2147483647
      -017777777777
      -0x7fffffff
    End

    It "入力 $1 から1を減算して最小値を得ること"
      When run efu_run sub1_check_value "$1" -2147483648
      The status should be success
      The stdout should equal ''
      The stderr should equal ''
    End
  End

  Context '64ビット設定の最小値'
    Skip if 'ホストの算術展開が64bit未満のため' arith_lt64
    Before 'sx_cfg_set NUM_RANGE=64'

    Parameters
      -9223372036854775807
      -0777777777777777777777
      -0x7fffffffffffffff
    End

    It "入力 $1 から1を減算して最小値を得ること"
      When run efu_run sub1_check_value "$1" -9223372036854775808
      The status should be success
      The stdout should equal ''
      The stderr should equal ''
    End
  End
End
