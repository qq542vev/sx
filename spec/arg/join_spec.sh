Describe 'sx_arg_join'
  Include ./sx.sh
  It 'joins arguments with a separator'
    When call sx_arg_join result ":" "a" "b" "c"
    The status should be success
    The variable result should equal "a:b:c"
  End

  It 'handles empty separator'
    When call sx_arg_join result "" "a" "b" "c"
    The status should be success
    The variable result should equal "abc"
  End

  It 'handles no arguments'
    When call sx_arg_join result ":"
    The status should be success
    The variable result should equal ""
  End
End
