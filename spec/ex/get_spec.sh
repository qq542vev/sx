Describe 'sx_ex_get'
  Include ./sx.sh

  Describe 'resolve name to status'
    It 'resolves OK to 0'
      When call sx_ex_get s=OK
      The status should be success
      The variable s should equal 0
    End

    It 'resolves DATAERR to 65'
      When call sx_ex_get s=DATAERR
      The status should be success
      The variable s should equal 65
    End
  End

  Describe 'resolve status to name'
    It 'resolves 0 to OK'
      When call sx_ex_get s=0
      The status should be success
      The variable s should equal 'OK'
    End

    It 'resolves 65 to DATAERR'
      When call sx_ex_get s=65
      The status should be success
      The variable s should equal 'DATAERR'
    End

    It 'returns status 1 if no name exists for status'
      When call sx_ex_get s=1
      The status should equal 1
      The variable s should be undefined
    End
  End

  Describe 'validation'
    It 'rejects numeric status 255 (not in map)'
      When call sx_ex_get 255
      The status should equal 1
    End

    It 'rejects invalid status 256'
      When call sx_ex_get 256
      The status should equal 1
    End

    It 'rejects unknown name'
      When call sx_ex_get UNKNOWN_NAME
      The status should equal 1
    End

    It 'accepts valid name without assignment'
      When call sx_ex_get OK
      The status should be success
    End

    It 'accepts valid status without assignment'
      When call sx_ex_get 0
      The status should be success
    End
  End

  Describe 'error handling'
    It 'returns EX_USAGE (64) for invalid variable names'
      When call sx_ex_get '1var=OK'
      The status should equal 64
    End

    It 'returns EX_NOPERM (77) for read-only variables'
      readonly ro_var=0
      When call sx_ex_get ro_var=OK
      The status should equal 77
    End
  End

  Describe 'multiple arguments'
    It 'resolves multiple variables and validates names'
      When call sx_ex_get s1=OK s2=65
      The status should be success
      The variable s1 should equal 0
      The variable s2 should equal 'DATAERR'
    End

    It 'fails if any value is invalid'
      When call sx_ex_get s1=OK s2=INVALID
      The status should equal 1
    End

    It 'fails if any variable name is invalid'
      When call sx_ex_get s1=OK '2s=65'
      The status should equal 64
    End

    It 'fails if any variable is read-only'
      readonly ro_var2=0
      When call sx_ex_get s1=OK ro_var2=65
      The status should equal 77
    End
  End

  Describe '高速モード (SX_CFG_SKIP_CHK=1)'
    It 'skips validation and resolves names'
      SX_CFG_SKIP_CHK=1
      When call sx_ex_get s=OK
      The status should be success
      The variable s should equal 0
    End

    It 'fails for unknown name'
      SX_CFG_SKIP_CHK=1
      When call sx_ex_get s=UNKNOWN
      The status should equal 1
      The variable s should be undefined
    End
  End
End
