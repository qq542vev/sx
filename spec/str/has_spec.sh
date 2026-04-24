Describe 'sx_str_has'
  Include ./sx.sh
  It 'returns success if the first argument contains any subsequent argument'
    When call sx_str_has "hello world" "world"
    The status should be success
  End

  It 'returns failure if no match is found'
    When call sx_str_has "hello world" "earth"
    The status should be failure
  End

  It 'returns success if searching for an empty string'
    When call sx_str_has "hello" ""
    The status should be success
  End
End
