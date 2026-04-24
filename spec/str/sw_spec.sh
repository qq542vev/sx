Describe 'sx_str_sw'
  Include ./sx.sh
  It 'returns success if the first argument starts with any subsequent argument'
    When call sx_str_sw "hello world" "hell"
    The status should be success
  End

  It 'returns failure if it does not start with any of the arguments'
    When call sx_str_sw "hello world" "world"
    The status should be failure
  End
End
