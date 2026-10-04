# shellcheck shell=sh
# ShellSpecのParameters内の負数をコマンド名として解釈する診断を抑制する。
# shellcheck disable=SC2215

Describe 'sx_num_divfloor_arith -efu 環境検証'
  Include ./sx.sh
  Before 'sx_cfg_set NUM_RANGE=32'

  divfloor_check_value() {
    expected="$1"
    shift
    result=old
    sx_num_divfloor_arith result "$@"
    case "$result" in "$expected") ;; *) return 1;; esac
    check_no_leak
  }

  Context '丸め結果と内部変数の解放'
    Parameters
      0
      7 7 ''
      3 7 2
      -4 -7 2
      -4 7 -2
      3 -7 -2
      0 1 2
      -1 -1 2
      -1 1 -2
      0 -1 -2
      2 +010 0x3
      -3 -010 +0X3
      -2147483648 -2147483648 1
      -715827883 -2147483648 3
      715827882 -2147483648 -3
      -1 2147483647 -2147483648
      -1 1 -2147483648
      0 -1 -2147483648
    End

    It "引数列 $* の結果を-e下で検証すること"
      When run efu_run divfloor_check_value "$@"
      The status should be success
      The stdout should equal ''
      The stderr should equal ''
    End
  End

  Context '不正な入力'
    Parameters
      7 0
      7 -0X0
      -2147483648 -1
      -0x80000000 -01
      08 2
      7 abc
      2147483648 1
    End

    It "引数列 $* を64で拒否すること"
      When run efu_run sx_num_divfloor_arith result "$@"
      The status should equal 64
      The stdout should equal ''
      The stderr should equal ''
    End
  End

  It '不正な設定を78で拒否すること'
    SX_CFG_NUM_RANGE=invalid
    When run efu_run sx_num_divfloor_arith result 7 2
    The status should equal 78
  End

  It 'チェック省略時も安全な除算の結果を返すこと'
    SX_CFG_SKIP_CHK=1
    When run efu_run divfloor_check_value -3 -010 0x3
    The status should be success
  End

  Context '64ビット設定'
    arith_lt64() { ( : $(( 0x7FFFFFFF + 1 )) ) 2>&- || return 0; return 1; }
    Skip if 'ホストの算術展開が64bit未満のため' arith_lt64
    Before 'sx_cfg_set NUM_RANGE=64'

    Context '丸め結果'
      Parameters
        -9223372036854775808 -9223372036854775808 1
        -3074457345618258603 -9223372036854775808 3
        3074457345618258602 -9223372036854775808 -3
        -2 -9223372036854775808 9223372036854775807
        -1 9223372036854775807 -9223372036854775808
        -1 1 -0x8000000000000000
        0 -1 -9223372036854775808
      End

      It "引数列 $* の結果を-e下で検証すること"
        When run efu_run divfloor_check_value "$@"
        The status should be success
        The stderr should equal ''
      End
    End

    It 'MIN / -1を演算前に64で拒否すること'
      When run efu_run sx_num_divfloor_arith result -9223372036854775808 -1
      The status should equal 64
      The stdout should equal ''
      The stderr should equal ''
    End
  End
End
