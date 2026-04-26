Describe 'sx_var_is_rw_all'
  Include ./sx.sh

  It 'すべての変数が書き込み可能な場合に成功を返すこと'
    v1=1 v2=2
    When call sx_var_is_rw_all v1 v2
    The status should be success
  End

  It '読み取り専用変数が含まれる場合に失敗を返すこと'
    v1=1
    readonly v2_ro=2
    When call sx_var_is_rw_all v1 v2_ro
    The status should be failure
  End

  It '配列の要素が読み取り専用の場合に失敗を返すこと'
    sx_arr_gen myarr a b
    readonly myarr_0
    When call sx_var_is_rw_all myarr
    The status should be failure
  End

  It '無効な変数名に対して EX_USAGE を返すこと'
    When call sx_var_is_rw_all "invalid-name"
    The status should equal 64
  End
End
