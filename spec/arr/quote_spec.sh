#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_arr_quote'
  Include ./sx.sh

  setup() {
    sx_arr_gen arr1 "hello world" "it's me"
    sx_arr_gen arr2 "back\\slash" '"double quotes"'
    sx_arr_gen arr_empty
  }

  cleanup() {
    sx_var_unset arr1 arr2 arr_empty result
  }

  It '単一の配列を安全にエンコードし、eval で復元できること'
    setup
    When call sx_arr_quote result arr1
    The status should be success
    
    eval "set -- $result"
    res1=$1 res2=$2 cnt=$#
    The variable res1 should equal "hello world"
    The variable res2 should equal "it's me"
    The variable cnt should equal 2
    cleanup
  End

  It '複数の配列を順番にエンコードし、結合できること'
    setup
    When call sx_arr_quote result arr1 arr2
    The status should be success
    
    eval "set -- $result"
    res1=$1 res2=$2 res3=$3 res4=$4 cnt=$#
    The variable res1 should equal "hello world"
    The variable res2 should equal "it's me"
    The variable res3 should equal 'back\slash'
    The variable res4 should equal '"double quotes"'
    The variable cnt should equal 4
    cleanup
  End

  It '空の配列をスキップして処理できること'
    setup
    When call sx_arr_quote result arr_empty arr1 arr_empty arr2
    The status should be success
    
    eval "set -- $result"
    res1=$1 res2=$2 res3=$3 res4=$4 cnt=$#
    The variable res1 should equal "hello world"
    The variable res2 should equal "it's me"
    The variable res3 should equal 'back\slash'
    The variable res4 should equal '"double quotes"'
    The variable cnt should equal 4
    cleanup
  End

  It 'すべて空の配列の場合、空文字列を返すこと'
    setup
    When call sx_arr_quote result arr_empty arr_empty
    The status should be success
    The variable result should equal ""
    cleanup
  End

  It '配列ではない引数が含まれる場合に EX_USAGE を返すこと'
    setup
    not_arr="not an array"
    When call sx_arr_quote result arr1 not_arr
    The status should equal 64
    cleanup
  End

  It '結果変数が読み取り専用の場合に EX_NOPERM を返すこと'
    setup
    readonly ro_res_arr_quote="fixed"
    When call sx_arr_quote ro_res_arr_quote arr1
    The status should equal 77
    cleanup
  End
End

Describe 'sx_arr_rquote'
  Include ./sx.sh

  setup() {
    sx_arr_gen arr1 "hello world" "it's me"
    sx_arr_gen arr2 "back\\slash" '"double quotes"'
    sx_arr_gen arr_empty
  }

  cleanup() {
    sx_var_unset arr1 arr2 arr_empty result
  }

  It '単一の配列を逆順で安全にエンコードし、eval で復元できること'
    setup
    When call sx_arr_rquote result arr1
    The status should be success
    
    eval "set -- $result"
    res1=$1 res2=$2 cnt=$#
    The variable res1 should equal "it's me"
    The variable res2 should equal "hello world"
    The variable cnt should equal 2
    cleanup
  End

  It '複数の配列を完全に逆順でエンコードし、結合できること'
    setup
    When call sx_arr_rquote result arr1 arr2
    The status should be success
    
    eval "set -- $result"
    res1=$1 res2=$2 res3=$3 res4=$4 cnt=$#
    The variable res1 should equal '"double quotes"'
    The variable res2 should equal 'back\slash'
    The variable res3 should equal "it's me"
    The variable res4 should equal "hello world"
    The variable cnt should equal 4
    cleanup
  End

  It '結果変数が読み取り専用の場合に EX_NOPERM を返すこと'
    setup
    readonly ro_res_arr_rquote="fixed"
    When call sx_arr_rquote ro_res_arr_rquote arr1
    The status should equal 77
    cleanup
  End
End
