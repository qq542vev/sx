Describe 'sx_var_has_val'
  Include ./sx.sh
  It 'すべての変数が空ではない値を持っている場合に成功を返すこと'
    a=1 b=0
    When call sx_var_has_val a b
    The status should be success
  End

  It 'いずれかの変数が空の場合に失敗を返すこと'
    a=1 b=""
    When call sx_var_has_val a b
    The status should be failure
  End

  It 'いずれかの変数が未設定の場合に失敗を返すこと'
    a=1
    unset c
    When call sx_var_has_val a c
    The status should be failure
  End

  It '無効な変数名に対して EX_USAGE を返すこと'
    When call sx_var_has_val "1invalid"
    The status should equal 64
  End
End
