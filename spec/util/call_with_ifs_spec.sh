Describe 'sx_call_with_ifs'
  Include ./sx.sh
  It 'executes a command with a temporary IFS'
    func() {
      echo "$#"
    }
    When call sx_call_with_ifs "," func "a,b,c"
    The status should be success
    The stdout should equal "3"
  End

  It 'restores the original IFS'
    IFS=":"
    sx_call_with_ifs "," true
    The variable IFS should equal ":"
  End
End
