# shellcheck shell=sh
# ShellSpecのParameters内の値をシェルコードとして解釈する診断を抑制する。
# shellcheck disable=SC2215

Describe 'sx_num_divmod_arith -efu 環境検証'
  Include ./sx.sh
  Before 'sx_cfg_set NUM_RANGE=32'

  divmod_check_values() {
    expected_q="$1" expected_r="$2"
    shift 2
    q=old_q r=old_r
    sx_num_divmod_arith 'q:r:' "$@"
    case "${q}:${r}" in "${expected_q}:${expected_r}") ;; *) return 1;; esac
    check_no_leak
  }

  Context '正常動作と内部変数の解放'
    Parameters
      0 0
      7 0 7 ''
      -3 -1 -7 2
      -2 -2 -010 0x3
      -2147483648 0 -2147483648 1
      -715827882 -2 -2147483648 3
    End

    It "引数列 $* の結果を-e下で検証すること"
      When run efu_run divmod_check_values "$@"
      The status should be success
      The stdout should equal ''
      The stderr should equal ''
    End
  End

  Context '安全でない入力をシェル終了前に拒否すること'
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
      When run efu_run sx_num_divmod_arith 'q:r:' "$@"
      The status should equal 64
      The stdout should equal ''
      The stderr should equal ''
    End
  End

  It '商のみのバインドで枯渇しても成功すること'
    When run efu_run sx_num_divmod_arith 'q:' 7 2
    The status should be success
  End

  It '不正な設定を78で拒否すること'
    SX_CFG_NUM_RANGE=invalid
    When run efu_run sx_num_divmod_arith 'q:r:' 7 2
    The status should equal 78
  End

  It 'チェック省略時も正常動作すること'
    SX_CFG_SKIP_CHK=1
    When run efu_run divmod_check_values -3 -1 -7 2
    The status should be success
  End

  Context '64ビット設定'
    Skip if 'ホストの算術展開が64bit未満のため' arith_lt64
    Before 'sx_cfg_set NUM_RANGE=64'

    It '最小値の安全な除算ができること'
      When run efu_run divmod_check_values -3074457345618258602 -2 -9223372036854775808 3
      The status should be success
      The stderr should equal ''
    End

    It '最小値を-1で割る前に64で拒否すること'
      When run efu_run sx_num_divmod_arith 'q:r:' -9223372036854775808 -1
      The status should equal 64
      The stdout should equal ''
      The stderr should equal ''
    End
  End
End
