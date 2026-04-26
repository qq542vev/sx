Describe 'sx_var_rw_chk'
  Include ./sx.sh

  It '書き込み可能な変数名に対して成功を返すこと'
    v1=a
    When call sx_var_rw_chk v1
    The status should be success
  End

  It '読み取り専用変数が含まれる場合に EX_NOPERM を返すこと'
    readonly ro_var_chk=ro
    When call sx_var_rw_chk ro_var_chk
    The status should equal 77
  End

  It '無効な変数名に対して EX_USAGE を返すこと'
    When call sx_var_rw_chk "1invalid"
    The status should equal 64
  End

  It '配列全体が書き込み可能か確認すること'
    sx_arr_gen myarr a b
    readonly myarr_1
    When call sx_var_rw_chk myarr
    The status should equal 77
  End
End
