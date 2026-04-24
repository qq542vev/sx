Describe 'sx_var_move'
  Include ./sx.sh
  It 'performs right shift move (v1 -> v2 -> v3, v1 is unset)'
    v1=AAA v2=BBB v3=CCC
    When call sx_var_move v1 v2 v3
    The status should be success
    The variable v1 should be undefined
    The variable v2 should equal "AAA"
    The variable v3 should equal "BBB"
  End

  It 'unsets the variable if only one argument is provided'
    v1=AAA
    When call sx_var_move v1
    The status should be success
    The variable v1 should be undefined
  End
End
