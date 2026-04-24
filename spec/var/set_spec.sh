Describe 'sx_var_set'
  Include ./sx.sh
  It 'sets multiple variables'
    When call sx_var_set v1=a v2=b
    The status should be success
    The variable v1 should equal "a"
    The variable v2 should equal "b"
  End

  It 'unsets variables if no value is provided'
    v1=a v2=b
    When call sx_var_set v1 v2
    The status should be success
    The variable v1 should be undefined
    The variable v2 should be undefined
  End

  It 'returns failure if any variable is readonly'
    readonly r1_set=ro
    When call sx_var_set v3=c r1_set=err v4=d
    The status should equal 77
    The variable v3 should be undefined
    The variable v4 should be undefined
  End
End
