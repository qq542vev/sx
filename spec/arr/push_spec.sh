Describe 'sx_arr_push'
  Include ./sx.sh
  BeforeEach 'sx_arr_gen myarr a'

  It '要素を配列の末尾に追加すること'
    When call sx_arr_push myarr b c
    The status should be success
    The variable myarr_len should equal 3
    The variable myarr_0 should equal "a"
    The variable myarr_1 should equal "b"
    The variable myarr_2 should equal "c"
  End

  It '値が指定されない場合は何もしないこと'
    When call sx_arr_push myarr
    The status should be success
    The variable myarr_len should equal 1
  End

  It '対象が配列でない場合に失敗を返すこと'
    not_an_arr="val"
    When call sx_arr_push not_an_arr x
    The status should equal 65 # SX_EX_DATAERR
  End
End
