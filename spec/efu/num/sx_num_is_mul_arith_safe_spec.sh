# shellcheck shell=sh

Describe 'sx_num_is_mul_arith_safe -efu 環境検証'
  Include ./sx.sh
  Before 'sx_cfg_set NUM_RANGE=32'

  Context '32ビットの乗算可能性'
    Parameters
      0 -2147483648 1
      0 46340 46340
      0 0 2147483647 2
      1 2147483647 2
      1 -2147483648 -1
      1 -1 -2147483648
      1 2147483647 2 0
      64 0x80000000
    End

    It "引数列 $* の終了ステータスを返すこと"
      expected="$1"
      shift
      When run efu_run sx_num_is_mul_arith_safe "$@"
      The status should equal "${expected}"
      The stdout should equal ''
      The stderr should equal ''
    End
  End

  It '不正な設定を78で拒否すること'
    SX_CFG_NUM_RANGE=invalid
    When run efu_run sx_num_is_mul_arith_safe 1
    The status should equal 78
  End

  It 'チェック省略時も桁溢れを1で判定すること'
    SX_CFG_SKIP_CHK=1
    When run efu_run sx_num_is_mul_arith_safe 2147483647 2
    The status should equal 1
  End

  Context '32bit算術シェル専用の算術域境界'
    Skip if '32bit算術シェル専用のため' arith_not32
    Before 'sx_cfg_set NUM_RANGE=32'

    It '負数を含む最大値付近の乗算可能性を-e下で判定すること'
      When run efu_run sx_num_is_mul_arith_safe -46340 46340
      The status should be success
      The stdout should equal ''
      The stderr should equal ''
    End
  End

  Context '64ビット設定'
    Skip if 'ホストの算術展開が64bit未満のため' arith_lt64
    Before 'sx_cfg_set NUM_RANGE=64'

    Parameters
      0 -9223372036854775808 1
      0 -3037000499 3037000499
      1 9223372036854775807 2
      1 -9223372036854775808 -1
      1 -1 -9223372036854775808
    End

    It "引数列 $* の判定を-e下で完了すること"
      expected="$1"
      shift
      When run efu_run sx_num_is_mul_arith_safe "$@"
      The status should equal "${expected}"
      The stdout should equal ''
      The stderr should equal ''
    End
  End
End
