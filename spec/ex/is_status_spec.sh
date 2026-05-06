Describe 'sx_ex_is_status'
  Include ./sx.sh

  Describe 'valid decimal status'
    It 'validates 0'
      When call sx_ex_is_status 0
      The status should be success
    End

    It 'validates 1'
      When call sx_ex_is_status 1
      The status should be success
    End

    It 'validates 255'
      When call sx_ex_is_status 255
      The status should be success
    End
  End

  Describe 'invalid status'
    It 'rejects 256'
      When call sx_ex_is_status 256
      The status should be failure
    End

    It 'rejects -1'
      When call sx_ex_is_status -1
      The status should be failure
    End

    It 'rejects alphabetic characters'
      When call sx_ex_is_status abc
      The status should be failure
    End

    It 'rejects leading zeros (except 0)'
      When call sx_ex_is_status 01
      The status should be failure
    End

    It 'rejects hexadecimal'
      When call sx_ex_is_status 0x10
      The status should be failure
    End
  End

  Describe 'multiple arguments'
    It 'validates multiple valid statuses'
      When call sx_ex_is_status 0 100 255
      The status should be success
    End

    It 'rejects if any status is invalid'
      When call sx_ex_is_status 0 256 255
      The status should be failure
    End
  End
End
