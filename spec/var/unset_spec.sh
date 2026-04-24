Describe 'sx_var_unset'
  Include ./sx.sh
  It '通常の変数を未設定にする'
    a=1
    When call sx_var_unset a
    The status should be success
    The variable a should be undefined
  End

  It '配列とそのすべての要素を未設定にする'
    sx_arr_gen myarr a b c
    When call sx_var_unset myarr
    The status should be success
    The variable myarr should be undefined
    The variable myarr_len should be undefined
    The variable myarr_0 should be undefined
    The variable myarr_2 should be undefined
  End

  It '変数が読み取り専用の場合（未設定であっても）に失敗を返す'
    readonly ro_var_unset
    When call sx_var_unset ro_var_unset
    The status should equal 77
  End
End
