#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_var_copy'
  Include ./sx.sh

  Describe 'スカラー変数のコピー'
    It '単一のコピー (v1 -> v2) が成功すること'
      v1="val1"
      When call sx_var_copy v1-v2
      The status should be success
      The variable v2 should equal "val1"
    End

    It '右から左へのコピー (v1 <- v2) が成功すること'
      v2="val2"
      When call sx_var_copy v1=v2
      The status should be success
      The variable v1 should equal "val2"
    End

    It '連鎖的なコピー (v1 -> v2 -> v3) が成功すること'
      v1="new" v2="old"
      When call sx_var_copy v1-v2-v3
      The status should be success
      The variable v2 should equal "new"
      The variable v3 should equal "old"
    End

    It '未定義の変数をコピーした場合、コピー先が unset されること'
      unset -v v1 v2
      v2="target"
      When call sx_var_copy v1-v2
      The status should be success
      The variable v2 should be undefined
    End

    It '自分自身へのコピーが副作用なく成功すること'
      v1="stay"
      When call sx_var_copy v1-v1
      The status should be success
      The variable v1 should equal "stay"
    End
  End

  Describe '配列のコピー'
    It '配列構造全体がコピーされること'
      sx_arr_gen arr1 "a" "b"
      When call sx_var_copy arr1-arr2
      The status should be success
      The variable arr2_len should equal 2
      The variable arr2_0 should equal "a"
      The variable arr2_1 should equal "b"
      The variable arr2 should start with "array-sx-sig-"
    End

    It '配列の連鎖コピーが成功すること'
      sx_arr_gen arr1 "a"
      sx_arr_gen arr2 "b"
      When call sx_var_copy arr1-arr2-arr3
      The status should be success
      The variable arr2_len should equal 1
      The variable arr2_0 should equal "a"
      The variable arr3_len should equal 1
      The variable arr3_0 should equal "b"
    End
  End

  Describe 'エラーケース'
    It '無効な連鎖式に対して EX_USAGE を返すこと'
      When call sx_var_copy "invalid-@name"
      The status should equal 64
    End

    It 'コピー先が読み取り専用の場合に EX_NOPERM を返すこと'
      readonly ro_var="fixed"
      v1="change"
      When call sx_var_copy v1-ro_var
      The status should equal 77
    End
  End

  Describe '境界ケース'
    It '配列の内容をスカラー変数にコピーすると配列シグネチャがコピーされること'
      sx_arr_gen src_arr a b
      When call sx_var_copy src_arr-dst_arr
      The variable dst_arr should start with "array-"
    End

    It 'スカラー変数の値を配列にコピーすると配列の値が変わること'
      src_val="value"
      sx_arr_gen dst_val x
      When call sx_var_copy src_val-dst_val
      The variable dst_val should equal "value"
    End

    It '連鎖コピーの途中に読み取り専用があった場合、中間状態がロールバックされること'
      a_roll=1
      readonly b_roll=0
      c_roll=3
      When call sx_var_copy a_roll-b_roll-c_roll
      The status should equal 77
      The variable a_roll should equal "1"
      The variable c_roll should equal "3"
    End
  End
End
