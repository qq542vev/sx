Describe 'sx_var_is_rw'
  Include ./sx.sh
  It '書き込み可能な変数の場合に成功を返すこと'
    a=1
    When call sx_var_is_rw a
    The status should be success
  End

  It '読み取り専用変数の場合に失敗を返すこと'
    readonly b_readonly=2
    When call sx_var_is_rw b_readonly
    The status should be failure
  End

  It '存在しない変数の場合に成功を返すこと（作成可能であるため）'
    unset c_nonexistent
    When call sx_var_is_rw c_nonexistent
    The status should be success
  End

  It '無効な変数名に対して EX_USAGE を返すこと'
    When call sx_var_is_rw "1invalid"
    The status should equal 64
  End
End
