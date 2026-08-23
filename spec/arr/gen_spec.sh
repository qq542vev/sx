#!/bin/sh

eval "$(shellspec - -c) exit 1"

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

  It '空文字列の要素を含む配列を生成できること'
    When call sx_arr_gen myarr_gen "a" "" "b"
    The variable myarr_gen_len should equal 3
    The variable myarr_gen_0 should equal "a"
    The variable myarr_gen_1 should equal ""
    The variable myarr_gen_2 should equal "b"
  End

  It '要素に特殊文字（シングルクォート）を含む配列を生成できること'
    When call sx_arr_gen myarr_q "it's" "test"
    The variable myarr_q_0 should equal "it's"
    The variable myarr_q_1 should equal "test"
  End

  It '連続してgenを呼び出しても毎回正しく初期化されること'
    sx_var_set myarr_seq
    sx_arr_gen myarr_seq first
    When call sx_arr_gen myarr_seq second
    The variable myarr_seq_len should equal 1
    The variable myarr_seq_0 should equal "second"
  End

  It '10個の要素で配列を初期化できること'
    When call sx_arr_gen myarr10 a b c d e f g h i j
    The variable myarr10_len should equal 10
  End
End
