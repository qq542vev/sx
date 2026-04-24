Describe 'sx_var_is_rw'
  Include ./sx.sh
  It '書き込み可能な変数の場合に成功を返す'
    a=1
    When call sx_var_is_rw a
    The status should be success
  End

  It '読み取り専用変数の場合に失敗を返す'
    # Use a subshell or a variable that we can make readonly and then it will be cleaned up
    # Shellspec's Describe/Context usually run in a way that allows cleanup
    readonly b_readonly=2
    When call sx_var_is_rw b_readonly
    The status should be failure
  End

  It '存在しない変数の場合に成功を返す（作成可能であるため）'
    unset c_nonexistent
    When call sx_var_is_rw c_nonexistent
    The status should be success
  End
End
