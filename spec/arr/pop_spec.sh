Describe 'sx_arr_pop'
  Include ./sx.sh
  BeforeEach 'sx_arr_gen myarr a b c'

  It 'デフォルトで最後の要素を取り出して破棄すること'
    When call sx_arr_pop myarr
    The status should be success
    The variable myarr_len should equal 2
    The variable myarr_2 should be undefined
  End

  It '最後の要素を変数に取り出すこと'
    When call sx_arr_pop myarr v1
    The status should be success
    The variable v1 should equal "c"
    The variable myarr_len should equal 2
    The variable myarr_2 should be undefined
  End

  It '複数の要素を変数に取り出すこと'
    When call sx_arr_pop myarr v1 v2
    The status should be success
    The variable v1 should equal "c"
    The variable v2 should equal "b"
    The variable myarr_len should equal 1
    The variable myarr_2 should be undefined
    The variable myarr_1 should be undefined
  End

  It '数値引数を使用して複数の要素を取り出して破棄すること'
    When call sx_arr_pop myarr 2
    The status should be success
    The variable myarr_len should equal 1
    The variable myarr_2 should be undefined
    The variable myarr_1 should be undefined
  End

  It '0個の要素の取り出しを処理できること'
    When call sx_arr_pop myarr 0
    The status should be success
    The variable myarr_len should equal 3
  End

  It '存在する要素数より多くの要素を取り出そうとした場合に失敗を返すこと'
    When call sx_arr_pop myarr 4
    The status should be failure
  End

  It '対象が配列でない場合に失敗を返すこと'
    not_an_arr="val"
    When call sx_arr_pop not_an_arr
    The status should equal 65 # SX_EX_DATAERR
  End
End
