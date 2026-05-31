Describe 'sx_num_cmp_arith'
  Include ./sx.sh

  It 'returns 1 when LHS < RHS'
    When call sx_num_cmp_arith 10 20
    The status should equal 1
  End

  It 'returns 2 when LHS == RHS'
    When call sx_num_cmp_arith 15 15
    The status should equal 2
  End

  It 'returns 3 when LHS > RHS'
    When call sx_num_cmp_arith 30 20
    The status should equal 3
  End

  It 'handles octal numbers correctly'
    When call sx_num_cmp_arith 010 8
    The status should equal 2
  End

  It 'handles hexadecimal numbers correctly'
    When call sx_num_cmp_arith 0x10 16
    The status should equal 2
  End

  It 'returns 64 for non-integer inputs'
    When call sx_num_cmp_arith 1.5 2
    The status should equal 64
  End

  It 'returns 64 for non-numeric inputs'
    When call sx_num_cmp_arith "abc" 10
    The status should equal 64
  End

  It 'skips check when SX_CFG_SKIP_CHK is 1'
    SX_CFG_SKIP_CHK=1
    When call sx_num_cmp_arith 10 20
    The status should equal 1
  End
End
