Describe 'sx_ex_yield'
  Include ./sx.sh

  Describe 'yield status'
    It 'yields 0 by default'
      When call sx_ex_yield
      The status should be success
      The status should equal 0
    End

    It 'yields 0 explicitly'
      When call sx_ex_yield 0
      The status should be success
      The status should equal 0
    End

    It 'yields 1'
      When call sx_ex_yield 1
      The status should be failure
      The status should equal 1
    End

    It 'yields 255'
      When call sx_ex_yield 255
      The status should be failure
      The status should equal 255
    End

    It 'yields SX_EX_USAGE (64)'
      When call sx_ex_yield 64
      The status should equal 64
    End

    It 'yields status by name (DATAERR -> 65)'
      When call sx_ex_yield DATAERR
      The status should equal 65
    End

    It 'yields status by name (OK -> 0)'
      When call sx_ex_yield OK
      The status should be success
    End
  End

  Describe 'invalid status'
    It 'returns SX_EX_USAGE (64) for 256'
      When call sx_ex_yield 256
      The status should equal 64
    End

    It 'returns SX_EX_USAGE (64) for -1'
      When call sx_ex_yield -1
      The status should equal 64
    End

    It 'returns SX_EX_USAGE (64) for non-numeric'
      When call sx_ex_yield abc
      The status should equal 64
    End
  End

  Describe 'with SX_CFG_SKIP_CHK=1'
    It 'yields 123 without validation'
      SX_CFG_SKIP_CHK=1
      When call sx_ex_yield 123
      The status should equal 123
    End

    It 'yields 0 by default without validation'
      SX_CFG_SKIP_CHK=1
      When call sx_ex_yield
      The status should equal 0
    End
    
    It 'yields 256 without validation (yash returns 256 as is)'
      SX_CFG_SKIP_CHK=1
      When call sx_ex_yield 256
      The status should equal 256
    End
  End
End
