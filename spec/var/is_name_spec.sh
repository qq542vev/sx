Describe 'sx_var_is_name'
  Include ./sx.sh
  It '有効な変数名に対して成功を返すこと'
    When call sx_var_is_name var1 _var VAR_123
    The status should be success
  End

  It '無効な変数名に対して失敗を返すこと'
    When call sx_var_is_name 1var
    The status should be failure
  End

  It '無効な文字を含む名前に対して失敗を返すこと'
    When call sx_var_is_name "var-name"
    The status should be failure
  End

  It 'いずれかの名前が無効な場合に失敗を返すこと'
    When call sx_var_is_name var1 1var
    The status should be failure
  End
End
