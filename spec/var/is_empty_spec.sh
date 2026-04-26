Describe 'sx_var_is_empty'
  Include ./sx.sh
  It 'すべての変数が設定されており、かつ空の場合に成功を返すこと'
    a="" b=""
    When call sx_var_is_empty a b
    The status should be success
  End

  It 'いずれかの変数が空ではない場合に失敗を返すこと'
    a="" b=1
    When call sx_var_is_empty a b
    The status should be failure
  End

  It 'いずれかの変数が未設定の場合に失敗を返すこと'
    unset c
    When call sx_var_is_empty c
    The status should be failure
  End

  It '無効な変数名に対して EX_USAGE を返すこと'
    When call sx_var_is_empty "1invalid"
    The status should equal 64
  End
End
