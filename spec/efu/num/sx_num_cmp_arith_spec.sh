Describe 'sx_num_cmp_arith -efu 環境検証'
  Include ./sx.sh

  It '正常動作'
    When run efu_run sx_num_cmp_arith 5 5
    The status should equal 2
  End

  Context '64ビット設定の最小値'
    arith_lt64() { ( : $(( 0x7FFFFFFF + 1 )) ) 2>&- || return 0; return 1; }
    Skip if 'ホストの算術展開が64bit未満のため' arith_lt64
    Before 'sx_cfg_set NUM_RANGE=64'

    It 'MIN を左辺として比較できること'
      When run efu_run sx_num_cmp_arith "${SX_SYS_NUM_MIN}" 0
      The status should equal 1
    End

    It 'MIN を右辺として比較できること'
      When run efu_run sx_num_cmp_arith 0 "${SX_SYS_NUM_MIN}"
      The status should equal 3
    End

    It 'MIN 同士を比較できること'
      When run efu_run sx_num_cmp_arith "${SX_SYS_NUM_MIN}" "${SX_SYS_NUM_MIN}"
      The status should equal 2
    End
  End
End
