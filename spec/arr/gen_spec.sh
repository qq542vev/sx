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

  It '空の配列を生成できること'
    When call sx_arr_gen empty_arr
    The status should be success
    The variable empty_arr_len should equal 0
    The variable empty_arr should start with "array-sx-sig-"
  End

  It '既存の配列を再初期化し、古い要素が削除されること'
    sx_arr_gen myarr a b c
    When call sx_arr_gen myarr x
    The status should be success
    The variable myarr_len should equal 1
    The variable myarr_0 should equal "x"
    The variable myarr_1 should be undefined
    The variable myarr_2 should be undefined
  End

  It '無効な配列名に対して EX_USAGE を返すこと'
    When call sx_arr_gen "1invalid" "val"
    The status should equal 64
  End

  It '配列名または長さ変数が読み取り専用の場合に EX_NOPERM を返すこと'
    sx_arr_gen ro_arr_gen a
    readonly ro_arr_gen
    When call sx_arr_gen ro_arr_gen x
    The status should equal 77
  End
End
