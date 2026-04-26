Describe 'sx_var_is_name'
  Include ./sx.sh
  It '有効な変数名に対して成功を返すこと'
    When call sx_var_is_name var1 _var VAR_123
    The status should be success
  End

  It '数字で始まる名前に対して失敗を返すこと'
    When call sx_var_is_name 1var
    The status should be failure
  End

  It '記号を含む名前に対して失敗を返すこと'
    When call sx_var_is_name "var-name" "var.name" "var name"
    The status should be failure
  End

  It '空文字列に対して失敗を返すこと'
    When call sx_var_is_name ""
    The status should be failure
  End

  It '引数がない場合に成功を返すこと'
    # 実装上、ループが回らないため成功する
    When call sx_var_is_name
    The status should be success
  End
End
