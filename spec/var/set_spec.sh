Describe 'sx_var_set'
  Include ./sx.sh
  It '複数の変数を設定すること'
    When call sx_var_set v1=a v2=b
    The status should be success
    The variable v1 should equal "a"
    The variable v2 should equal "b"
  End

  It '値が指定されない場合、変数を未設定にすること'
    v1=a v2=b
    When call sx_var_set v1 v2
    The status should be success
    The variable v1 should be undefined
    The variable v2 should be undefined
  End

  It 'いずれかの変数が読み取り専用の場合に EX_NOPERM を返すこと'
    readonly r1_set=ro
    When call sx_var_set v3=c r1_set=err v4=d
    The status should equal 77
    The variable v3 should be undefined
    The variable v4 should be undefined
  End

  It '配列名を指定した場合、配列全体（要素含む）を削除すること'
    sx_arr_gen myarr x y
    When call sx_var_set myarr
    The status should be success
    The variable myarr should be undefined
    The variable myarr_len should be undefined
    The variable myarr_0 should be undefined
  End
End
