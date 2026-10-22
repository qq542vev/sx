# shellcheck shell=sh
# ShellSpec: 参照渡しで設定される変数を使用する。
# shellcheck disable=SC2154
# ShellSpecのParameters内の負数をコマンドとして解釈する診断を抑制する。
# shellcheck disable=SC2215

Describe 'sx_num_add1_arith -efu 環境検証'
  Include ./spec/support/prepare.sh
  Include ./spec/support/library.sh sx_num_add1_arith
  Before 'sx_test_setup sx_cfg_set NUM_RANGE=32'

  It '正常な入力に1を加算すること'
    When run efu_run sx_num_add1_arith result -0x10
    The status should be success
  End

  It '不正な入力を64で拒否すること'
    When run efu_run sx_num_add1_arith result 08
    The status should equal 64
    The stderr should equal ''
  End

  It '桁溢れを64で拒否すること'
    When run efu_run sx_num_add1_arith result 2147483647
    The status should equal 64
    The stderr should equal ''
  End

  It '引数の省略を64で拒否すること'
    When run efu_run sx_num_add1_arith
    The status should equal 64
  End

  add1_min_check_value() {
    sx_num_add1_arith result "$1"
    case "$result" in "$2") ;; *) return 1;; esac
    check_no_leak
  }

  Context '32bit算術シェル専用の算術域境界'
    Skip if '32bit算術シェル専用のため' arith_not32

    Parameters
      -2147483648
      -020000000000
      -0x80000000
    End

    It "最小値 $1 に1を加算して結果を検証すること"
      When run efu_run add1_min_check_value "$1" -2147483647
      The status should be success
      The stdout should equal ''
      The stderr should equal ''
    End
  End

  Context '64ビット設定の最小値'
    Skip if 'ホストの算術展開が64bit未満のため' arith_lt64
    Before 'sx_test_setup sx_cfg_set NUM_RANGE=64'

    Parameters
      -9223372036854775808
      -01000000000000000000000
      -0x8000000000000000
    End

    It "最小値 $1 に1を加算して結果を検証すること"
      When run efu_run add1_min_check_value "$1" -9223372036854775807
      The status should be success
      The stdout should equal ''
      The stderr should equal ''
    End
  End
End
