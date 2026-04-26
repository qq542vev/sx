Describe 'sx_arr_is_rw'
  Include ./sx.sh

  It '指定された配列要素と長さ変数が書き込み可能な場合に成功を返すこと'
    arr_len=2 arr_0=a arr_1=b
    When call sx_arr_is_rw arr 0 2
    The status should be success
  End

  It '引数なしの場合、sx配列であれば全要素を確認すること'
    sx_arr_gen myarr a b c
    When call sx_arr_is_rw myarr
    The status should be success
  End

  It '要素が読み取り専用の場合に失敗を返すこと'
    arr_len=1 arr_0=a
    readonly arr_0
    When call sx_arr_is_rw arr 0 1
    The status should be failure
  End

  It '長さ変数が読み取り専用の場合に失敗を返すこと'
    arr_len=1 arr_0=a
    readonly arr_len
    When call sx_arr_is_rw arr 0 1
    The status should be failure
  End

  It '個数が省略された場合、sx配列であれば末尾まで確認すること'
    sx_arr_gen myarr a b c d
    When call sx_arr_is_rw myarr 2
    The status should be success
  End

  It '個数が省略された場合、sx配列でなければその要素のみ確認すること'
    other_var_0=a other_var_len=1
    When call sx_arr_is_rw other_var 0
    The status should be success
  End

  It '単一の配列に対して複数の範囲を指定できること'
    sx_arr_gen myarr a b c d e
    When call sx_arr_is_rw myarr 0 1 3 2
    The status should be success
  End

  It '無効な配列名に対して EX_USAGE を返すこと'
    When call sx_arr_is_rw "invalid-name"
    The status should equal 64
  End

  It '非数値のインデックスに対して EX_USAGE を返すこと'
    When call sx_arr_is_rw myarr "a"
    The status should equal 64
  End
End
