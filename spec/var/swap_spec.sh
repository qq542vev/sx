Describe 'sx_var_swap'
  Include ./sx.sh
  It '値を右に回転（v1 v2 v3 -> v3 v1 v2）させる'
    v1=AAA v2=BBB v3=CCC
    When call sx_var_swap v1 v2 v3
    The status should be success
    The variable v1 should equal "CCC"
    The variable v2 should equal "AAA"
    The variable v3 should equal "BBB"
  End

  It '引数が1つの場合は何もしない'
    v1=AAA
    When call sx_var_swap v1
    The status should be success
    The variable v1 should equal "AAA"
  End

  It '引数がない場合は何もしない'
    When call sx_var_swap
    The status should be success
  End
End
