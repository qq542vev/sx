Describe 'sx_num_cmp_arith'
  Include ./sx.sh

  It 'LHS < RHS の場合に 1 を返すこと'
    When call sx_num_cmp_arith 10 20
    The status should equal 1
  End

  It 'LHS == RHS の場合に 2 を返すこと'
    When call sx_num_cmp_arith 15 15
    The status should equal 2
  End

  It 'LHS > RHS の場合に 3 を返すこと'
    When call sx_num_cmp_arith 30 20
    The status should equal 3
  End

  It '8進数を正しく処理できること'
    When call sx_num_cmp_arith 010 8
    The status should equal 2
  End

  It '16進数を正しく処理できること'
    When call sx_num_cmp_arith 0x10 16
    The status should equal 2
  End

  It '整数以外の入力に対して 64 を返すこと'
    When call sx_num_cmp_arith 1.5 2
    The status should equal 64
  End

  It '数値以外の入力に対して 64 を返すこと'
    When call sx_num_cmp_arith "abc" 10
    The status should equal 64
  End

  It 'SX_CFG_SKIP_CHK が 1 の時にチェックをスキップすること'
    SX_CFG_SKIP_CHK=1
    When call sx_num_cmp_arith 10 20
    The status should equal 1
  End
End
