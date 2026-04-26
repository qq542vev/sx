Describe 'sx_var_move'
  Include ./sx.sh
  It '右方向連鎖移動（v1-v2-v3）を実行すること'
    v1=AAA v2=BBB v3=CCC
    When call sx_var_move v1-v2-v3
    The status should be success
    The variable v1 should be undefined
    The variable v2 should equal "AAA"
    The variable v3 should equal "BBB"
  End

  It '左方向連鎖移動（v1=v2=v3）を実行すること'
    v1=AAA v2=BBB v3=CCC
    When call sx_var_move v1=v2=v3
    The status should be success
    The variable v3 should be undefined
    The variable v2 should equal "CCC"
    The variable v1 should equal "BBB"
  End

  It '配列を移動できること'
    sx_arr_gen myarr a b
    When call sx_var_move myarr-newarr
    The status should be success
    The variable myarr should be undefined
    The variable myarr_len should be undefined
    The variable newarr_len should equal 2
    The variable newarr_0 should equal "a"
    The variable newarr_1 should equal "b"
  End

  It '移動先が読み取り専用の場合に EX_NOPERM を返すこと'
    v1=a
    readonly v2_ro=b
    When call sx_var_move v1-v2_ro
    The status should equal 77
    The variable v1 should equal "a"
  End

  It '移動元（削除対象）が読み取り専用の場合に EX_NOPERM を返すこと'
    readonly v1_ro=a
    v2=b
    When call sx_var_move v1_ro-v2
    The status should equal 77
  End

  It '無効な連鎖式に対して EX_USAGE を返すこと'
    When call sx_var_move "a+b"
    The status should equal 64
  End
End
