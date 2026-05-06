Describe 'sx_ex_is_err'
  Include ./sx.sh

  Describe 'valid decimal error status'
    It 'validates 1'
      When call sx_ex_is_err 1
      The status should be success
    End

    It 'validates 255'
      When call sx_ex_is_err 255
      The status should be success
    End
  End

  Describe 'invalid error status'
    It 'rejects 0'
      When call sx_ex_is_err 0
      The status should be failure
    End

    It 'rejects 256'
      When call sx_ex_is_err 256
      The status should be failure
    End

    It 'rejects -1'
      When call sx_ex_is_err -1
      The status should be failure
    End

    It 'rejects leading zeros'
      When call sx_ex_is_err 01
      The status should be failure
    End
  End

  Describe 'multiple arguments'
    It 'validates multiple valid error statuses'
      When call sx_ex_is_err 1 100 255
      The status should be success
    End

    It 'rejects if any status is invalid (including 0)'
      When call sx_ex_is_err 1 0 255
      The status should be failure
    End
  End
End
