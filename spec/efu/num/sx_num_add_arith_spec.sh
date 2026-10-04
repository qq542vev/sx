# shellcheck shell=sh
# ShellSpecのParameters内の負数をコマンドとして解釈する診断を抑制する。
# shellcheck disable=SC2215

Describe 'sx_num_add_arith -efu 環境検証'
  Include ./sx.sh
  Before 'sx_cfg_set NUM_RANGE=32'

  It '数値省略時も正常に終了すること'
    When run efu_run sx_num_add_arith result
    The status should be success
  End

  It '符号付きの8・10・16進整数を加算できること'
    When run efu_run sx_num_add_arith result +010 -0X10 20
    The status should be success
  End

  It '不正な入力を64で拒否すること'
    When run efu_run sx_num_add_arith result 1 08
    The status should equal 64
  End

  It '範囲外の入力を64で拒否すること'
    When run efu_run sx_num_add_arith result 0x80000000
    The status should equal 64
  End

  Context '32ビットの桁溢れ'
    Parameters
      2147483647 1 -1
      -2147483648 -1 1
    End

    It "引数列 $* の桁溢れを加算前に64で拒否すること"
      When run efu_run sx_num_add_arith result "$@"
      The status should equal 64
      The stderr should equal ''
    End
  End

  It '結果変数の省略を64で拒否すること'
    When run efu_run sx_num_add_arith
    The status should equal 64
  End

  It 'チェック省略時も加算できること'
    SX_CFG_SKIP_CHK=1
    When run efu_run sx_num_add_arith result 010 -0x10 20
    The status should be success
  End

  add_min_check_value() {
    result=old
    sx_num_add_arith result "$1" 1
    case "$result" in -2147483647) ;; *) return 1;; esac
    check_no_leak
  }

  Context '32bit算術シェル専用の算術域境界'
    Skip if '32bit算術シェル専用のため' arith_not32
    Before 'sx_cfg_set NUM_RANGE=32'

    Parameters
      -2147483648
      -020000000000
      -0x80000000
    End

    It "最小値 $1 に1を加算して-e下で結果を検証すること"
      When run efu_run add_min_check_value "$1"
      The status should be success
      The stdout should equal ''
      The stderr should equal ''
    End
  End

  Context '64ビット設定の最小値'
    Skip if 'ホストの算術展開が64bit未満のため' arith_lt64
    Before 'sx_cfg_set NUM_RANGE=64'

    Parameters
      -9223372036854775808
      -01000000000000000000000
      -0x8000000000000000
    End

    It "最小値 $1 を加算できること"
      When run efu_run sx_num_add_arith result "$1" 1
      The status should be success
    End
  End
End
