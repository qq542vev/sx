#!/bin/sh
# shellcheck disable=SC2016 # CMD内の変数は準備用シェルで展開する。
# ShellSpec: 参照渡しで設定される変数を使用する。
# shellcheck disable=SC2154

eval "$(shellspec - -c) exit 1"

Describe 'sx_arr_quote'
  Include ./spec/support/setup.sh
  Include ./spec/support/library.sh sx_arr_quote

  setup() {
    setup_command='
      SX_SYS_REV=$1
      sx_arr_gen arr1 "$2" "$3"
      sx_arr_gen arr2 "$4" "$5"
      sx_arr_gen arr_empty
    '
    sxtest_setup arr1 arr2 arr_empty SX_SYS_REV -- "$setup_command" "${SX_SYS_REV-0}" "hello world" "it's me" "back\\slash" '"double quotes"'
  }

  cleanup() {
    sxtest_setup arr1 arr1_len arr1_0 arr1_1 arr2 arr2_len arr2_0 arr2_1 arr_empty arr_empty_len result -- \
      'sx_var_unset "$@"' arr1 arr1_len arr1_0 arr1_1 arr2 arr2_len arr2_0 arr2_1 arr_empty arr_empty_len result
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

  It '疎配列の穴を既定（空文字）で表すこと'
    sxtest_setup sparse_arr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"; sx_var_unset sparse_arr_1' "${SX_SYS_REV-0}" sparse_arr a b c
    When call sx_arr_quote result sparse_arr
    The status should be success

    eval "set -- $result"
    res1=$1 res2=$2 res3=$3 cnt=$#
    The variable res1 should equal "a"
    The variable res2 should equal ""
    The variable res3 should equal "c"
    The variable cnt should equal 3
    sxtest_setup sparse_arr sparse_arr_len sparse_arr_0 sparse_arr_1 sparse_arr_2 result -- \
      'sx_var_unset "$@"' sparse_arr sparse_arr_len sparse_arr_0 sparse_arr_1 sparse_arr_2 result
  End

  It '疎配列の穴をSX_CFG_ARR_HOLEの値で表すこと'
    sxtest_setup sparse_arr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"; sx_var_unset sparse_arr_1' "${SX_SYS_REV-0}" sparse_arr a b c
    sxtest_setup SX_CFG_ARR_HOLE -- 'sx_cfg_set "$@"' "ARR_HOLE=HOLE"
    When call sx_arr_quote result sparse_arr
    The status should be success

    eval "set -- $result"
    res1=$1 res2=$2 res3=$3 cnt=$#
    The variable res1 should equal "a"
    The variable res2 should equal "HOLE"
    The variable res3 should equal "c"
    The variable cnt should equal 3
    sxtest_setup SX_CFG_ARR_HOLE -- 'sx_cfg_set "$@"' "ARR_HOLE"
    sxtest_setup sparse_arr sparse_arr_len sparse_arr_0 sparse_arr_1 sparse_arr_2 result -- \
      'sx_var_unset "$@"' sparse_arr sparse_arr_len sparse_arr_0 sparse_arr_1 sparse_arr_2 result
  End

  It '配列ではない引数が含まれる場合に EX_DATAERR を返すこと'
    setup
    not_arr="not an array"
    When call sx_arr_quote result arr1 not_arr
    The status should equal 65
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
  Include ./spec/support/setup.sh
  Include ./spec/support/library.sh sx_arr_rquote

  setup() {
    setup_command='
      SX_SYS_REV=$1
      sx_arr_gen arr1 "$2" "$3"
      sx_arr_gen arr2 "$4" "$5"
      sx_arr_gen arr_empty
    '
    sxtest_setup arr1 arr2 arr_empty SX_SYS_REV -- "$setup_command" "${SX_SYS_REV-0}" "hello world" "it's me" "back\\slash" '"double quotes"'
  }

  cleanup() {
    sxtest_setup arr1 arr1_len arr1_0 arr1_1 arr2 arr2_len arr2_0 arr2_1 arr_empty arr_empty_len result -- \
      'sx_var_unset "$@"' arr1 arr1_len arr1_0 arr1_1 arr2 arr2_len arr2_0 arr2_1 arr_empty arr_empty_len result
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

  It '配列ではない引数が含まれる場合に EX_DATAERR を返すこと'
    setup
    not_arr="not an array"
    When call sx_arr_rquote result arr1 not_arr
    The status should equal 65
    cleanup
  End

  It '疎配列の穴を既定（空文字）で逆順に表すこと'
    sxtest_setup sparse_arr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"; sx_var_unset sparse_arr_1' "${SX_SYS_REV-0}" sparse_arr a b c
    When call sx_arr_rquote result sparse_arr
    The status should be success

    eval "set -- $result"
    res1=$1 res2=$2 res3=$3 cnt=$#
    The variable res1 should equal "c"
    The variable res2 should equal ""
    The variable res3 should equal "a"
    The variable cnt should equal 3
    sxtest_setup sparse_arr sparse_arr_len sparse_arr_0 sparse_arr_1 sparse_arr_2 result -- \
      'sx_var_unset "$@"' sparse_arr sparse_arr_len sparse_arr_0 sparse_arr_1 sparse_arr_2 result
  End

  It '疎配列の穴をSX_CFG_ARR_HOLEの値で逆順に表すこと'
    sxtest_setup sparse_arr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"; sx_var_unset sparse_arr_1' "${SX_SYS_REV-0}" sparse_arr a b c
    sxtest_setup SX_CFG_ARR_HOLE -- 'sx_cfg_set "$@"' "ARR_HOLE=HOLE"
    When call sx_arr_rquote result sparse_arr
    The status should be success

    eval "set -- $result"
    res1=$1 res2=$2 res3=$3 cnt=$#
    The variable res1 should equal "c"
    The variable res2 should equal "HOLE"
    The variable res3 should equal "a"
    The variable cnt should equal 3
    sxtest_setup SX_CFG_ARR_HOLE -- 'sx_cfg_set "$@"' "ARR_HOLE"
    sxtest_setup sparse_arr sparse_arr_len sparse_arr_0 sparse_arr_1 sparse_arr_2 result -- \
      'sx_var_unset "$@"' sparse_arr sparse_arr_len sparse_arr_0 sparse_arr_1 sparse_arr_2 result
  End

  It '結果変数が読み取り専用の場合に EX_NOPERM を返すこと'
    setup
    readonly ro_res_arr_rquote="fixed"
    When call sx_arr_rquote ro_res_arr_rquote arr1
    The status should equal 77
    cleanup
  End
End
