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

  It '対象が sx 配列でない場合に EX_DATAERR を返すこと'
    not_an_arr="val"
    When call sx_arr_push not_an_arr x
    The status should equal 65
  End

  It '読み取り専用の配列に対して EX_NOPERM を返すこと'
    sx_arr_gen ro_arr_push
    readonly ro_arr_push
    When call sx_arr_push ro_arr_push x
    The status should equal 77
  End

  It '配列の長さ変数が読み取り専用の場合に EX_NOPERM を返すこと'
    sx_arr_gen len_ro_arr a
    readonly len_ro_arr_len
    When call sx_arr_push len_ro_arr b
    The status should equal 77
  End
End
