# shellcheck shell=sh

Describe 'sx_num_is_sub_arith_safe -efu 環境検証'
  Include ./sx.sh
  Before 'sx_cfg_set NUM_RANGE=32'

  Context '32ビットの減算可能性'
    Parameters
      0 -2147483648 -1
      0 2147483647 2147483647
      1 2147483647 -1
      1 -2147483648 1
      1 1 0 -2147483648
      64 08
    End

    It "引数列 $* の終了ステータスを返すこと"
      expected="$1"
      shift
      When run efu_run sx_num_is_sub_arith_safe "$@"
      The status should equal "${expected}"
      The stdout should equal ''
      The stderr should equal ''
    End
  End

  It '不正な設定を78で拒否すること'
    SX_CFG_NUM_RANGE=invalid
    When run efu_run sx_num_is_sub_arith_safe 1
    The status should equal 78
  End

  It 'チェック省略時も桁溢れを1で判定すること'
    SX_CFG_SKIP_CHK=1
    When run efu_run sx_num_is_sub_arith_safe 2147483647 -1
    The status should equal 1
  End

  Context '64ビット設定'
    arith_lt64() { ( : $(( 0x7FFFFFFF + 1 )) ) 2>&- || return 0; return 1; }
    Skip if 'ホストの算術展開が64bit未満のため' arith_lt64
    Before 'sx_cfg_set NUM_RANGE=64'

    Parameters
      0 -9223372036854775808 -1
      1 9223372036854775807 -1
      1 0 -9223372036854775808
    End

    It "引数列 $* の判定を-e下で完了すること"
      expected="$1"
      shift
      When run efu_run sx_num_is_sub_arith_safe "$@"
      The status should equal "${expected}"
      The stdout should equal ''
      The stderr should equal ''
    End
  End
End
