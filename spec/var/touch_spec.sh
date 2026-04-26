Describe 'sx_var_touch'
  Include ./sx.sh
  It '変数のリビジョンを更新すること'
    sx_arr_gen myarr a
    old_val="${myarr}"
    When call sx_var_touch myarr
    The status should be success
    The variable myarr should not equal "${old_val}"
    The variable myarr should start with "array-sx-sig-"
  End

  It '複数の変数を同時に更新できること'
    sx_arr_gen arr1 a
    sx_arr_gen arr2 b
    old1="${arr1}"
    old2="${arr2}"
    When call sx_var_touch arr1 arr2
    The status should be success
    The variable arr1 should not equal "${old1}"
    The variable arr2 should not equal "${old2}"
  End

  It '読み取り専用変数の場合に EX_NOPERM を返すこと'
    readonly ro_touch=ro
    When call sx_var_touch ro_touch
    The status should equal 77
  End

  It '無効な変数名に対して EX_USAGE を返すこと'
    When call sx_var_touch "1invalid"
    The status should equal 64
  End
End
