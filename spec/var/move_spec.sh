Describe 'sx_var_move'
  Include ./sx.sh
  It '右シフト移動（v1-v2-v3, v1 は未設定になる）を実行する'
    v1=AAA v2=BBB v3=CCC
    When call sx_var_move v1-v2-v3
    The status should be success
    The variable v1 should be undefined
    The variable v2 should equal "AAA"
    The variable v3 should equal "BBB"
  End

  It '引数が1つの場合、変数を未設定にする'
    v1=AAA
    When call sx_var_move v1
    The status should be success
    The variable v1 should be undefined
  End
End
