Describe 'var/copy.sh'
  Include ./sx.sh

  Describe 'sx_var_copy scalar'
    It '単一のコピー (v1 -> v2) が成功すること'
      v1="val1"
      sx_var_copy v1-v2
      The variable v2 should equal "val1"
    End

    It '右から左へのコピー (v1 <- v2) が成功すること'
      v2="val2"
      sx_var_copy v1=v2
      The variable v1 should equal "val2"
    End

    It '連鎖的なコピー (v1 -> v2 -> v3) が成功すること'
      v1="new" v2="old"
      sx_var_copy v1-v2-v3
      The variable v2 should equal "new"
      The variable v3 should equal "old"
    End

    It '逆方向の連鎖コピー (v1 <- v2 <- v3) が成功すること'
      v2="old" v3="new"
      sx_var_copy v1=v2=v3
      The variable v2 should equal "new"
      The variable v1 should equal "old"
    End

    It '未定義の変数をコピーした場合、コピー先が unset されること'
      unset -v v1 v2
      v2="target"
      sx_var_copy v1-v2
      The variable v2 should be undefined
    End
  End

  Describe 'sx_var_copy array'
    It '配列構造全体がコピーされること'
      sx_arr_gen arr1 "a" "b" "c"
      sx_var_copy arr1-arr2
      The variable arr2_len should equal 3
      The variable arr2_0 should equal "a"
      The variable arr2_1 should equal "b"
      The variable arr2_2 should equal "c"
      The variable arr2 should match pattern "${SX_SIG_ARR}:*"
      sx_var_unset arr1 arr2
    End

    It '配列の連鎖コピーが成功すること'
      sx_arr_gen arr1 "a" "b" "c"
      sx_arr_gen arr2 "d"
      sx_var_copy arr1-arr2-arr3
      The variable arr2_len should equal 3
      The variable arr3_len should equal 1
      The variable arr3_0 should equal "d"
      sx_var_unset arr1 arr2 arr3
    End
  End

  Describe 'sx_var_copy errors'
    It '無効な連鎖式に対して SX_EX_USAGE を返すこと'
      When call sx_var_copy "invalid-@name"
      The status should equal "$SX_EX_USAGE"
    End

    It '読み取り専用変数へのコピーに対して SX_EX_NOPERM を返すこと'
      readonly ro_var="fixed"
      v1="change"
      When call sx_var_copy v1-ro_var
      The status should equal "$SX_EX_NOPERM"
    End

    It '配列の一部（要素）が読み取り専用の場合も SX_EX_NOPERM を返すこと'
      sx_arr_gen arr_target "x"
      readonly arr_target_0
      sx_arr_gen arr_src "y"
      When call sx_var_copy arr_src-arr_target
      The status should equal "$SX_EX_NOPERM"
    End
  End

  Describe 'sx_var_copy special'
    It '自分自身へのコピーが副作用なく成功すること'
      v1="stay"
      sx_var_copy v1-v1
      The variable v1 should equal "stay"
    End

    It '複数の連鎖式を一度に処理できること'
      a=1 b=2 c=3 d=4
      sx_var_copy a-b c-d
      The variable b should equal 1
      The variable d should equal 3
    End
  End
End
