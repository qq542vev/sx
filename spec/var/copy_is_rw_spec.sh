Describe 'sx_var_copy_is_rw'
  Include ./sx.sh

  It 'コピー先の変数がすべて書き込み可能な場合に成功を返すこと'
    v1=a v2=b v3=c
    When call sx_var_copy_is_rw "v1-v2-v3"
    The status should be success
  End

  It 'コピー先に読み取り専用変数が含まれる場合に失敗を返すこと'
    v1=a
    readonly v2_ro=b
    When call sx_var_copy_is_rw "v1-v2_ro"
    The status should be failure
  End

  It '配列の要素が読み取り専用の場合に失敗を返すこと'
    sx_arr_gen myarr a b
    readonly myarr_1
    When call sx_var_copy_is_rw "src-myarr"
    The status should be failure
  End

  It '無効な連鎖式に対して EX_USAGE を返すこと'
    When call sx_var_copy_is_rw "a+b"
    The status should equal 64
  End
End
