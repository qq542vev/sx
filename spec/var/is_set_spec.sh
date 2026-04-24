Describe 'sx_var_is_set'
  Include ./sx.sh
  It 'すべての変数が設定されている場合に成功を返す'
    a=1 b=2
    When call sx_var_is_set a b
    The status should be success
  End

  It 'いずれかの変数が未設定の場合に失敗を返す'
    a=1
    unset b
    When call sx_var_is_set a b
    The status should be failure
  End

  It '存在しない変数の場合に失敗を返す'
    unset c
    When call sx_var_is_set c
    The status should be failure
  End
End
