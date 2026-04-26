Describe 'sx_var_is_set'
  Include ./sx.sh
  It 'すべての変数が設定されている場合に成功を返すこと'
    a=1 b=2
    When call sx_var_is_set a b
    The status should be success
  End

  It 'いずれかの変数が未設定の場合に失敗を返すこと'
    a=1
    unset b
    When call sx_var_is_set a b
    The status should be failure
  End

  It '無効な変数名に対して EX_USAGE を返すこと'
    When call sx_var_is_set "1invalid"
    The status should equal 64
  End
End
