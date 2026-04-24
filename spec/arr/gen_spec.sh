Describe 'sx_arr_gen'
  Include ./sx.sh
  It '新しい配列を値で初期化すること'
    When call sx_arr_gen myarr "first" "second"
    The status should be success
    The variable myarr_len should equal 2
    The variable myarr_0 should equal "first"
    The variable myarr_1 should equal "second"
    The variable myarr should start with "array-sx-sig-"
  End

  It '既存の配列を再初期化すること'
    sx_arr_gen myarr a b c
    When call sx_arr_gen myarr x
    The status should be success
    The variable myarr_len should equal 1
    The variable myarr_0 should equal "x"
    The variable myarr_1 should be undefined
    The variable myarr_2 should be undefined
  End
End
