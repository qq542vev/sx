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
  End

  It '存在する要素数より多くの要素を取り出そうとした場合に失敗(1)を返すこと'
    When call sx_arr_pop myarr 4
    The status should equal 1
  End

  It '結果変数が配列名と重複する場合に EX_USAGE を返すこと'
    When call sx_arr_pop myarr myarr
    The status should equal 64
  End

  It '結果変数が配列要素名と重複する場合に EX_USAGE を返すこと'
    When call sx_arr_pop myarr myarr_0
    The status should equal 64
  End

  It '読み取り専用の結果変数にポップしようとした場合に EX_NOPERM を返すこと'
    readonly ro_dest="fixed"
    When call sx_arr_pop myarr ro_dest
    The status should equal 77
  End

  It '対象が sx 配列でない場合に EX_DATAERR を返すこと'
    not_an_arr="val"
    When call sx_arr_pop not_an_arr
    The status should equal 65
  End
End
