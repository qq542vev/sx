Describe 'sx_str_ew'
  Include ./sx.sh
  It 'returns success if the first argument ends with any subsequent argument'
    When call sx_str_ew "hello world" "world"
    The status should be success
  End

  It 'returns failure if it does not end with any of the arguments'
    When call sx_str_ew "hello world" "hell"
    The status should be failure
  End
End
