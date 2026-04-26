Describe 'sx_var_is_ro'
  Include ./sx.sh
  It '書き込み可能な変数に対して失敗を返すこと'
    a=1
    When call sx_var_is_ro a
    The status should be failure
  End

  It '読み取り専用の変数に対して成功を返すこと'
    readonly b_ro=2
    When call sx_var_is_ro b_ro
    The status should be success
  End

  It '存在しない変数に対して失敗を返すこと'
    unset c_nonexistent
    When call sx_var_is_ro c_nonexistent
    The status should be failure
  End

  It '無効な変数名に対して EX_USAGE を返すこと'
    When call sx_var_is_ro "1invalid"
    The status should equal 64
  End
End
