Describe 'sx_var_is_arr'
  Include ./sx.sh
  It 'sx配列に対して成功を返すこと'
    sx_arr_gen myarr a b
    When call sx_var_is_arr myarr
    The status should be success
  End

  It '通常の変数に対して失敗を返すこと'
    regular_var="val"
    When call sx_var_is_arr regular_var
    The status should be failure
  End
End
