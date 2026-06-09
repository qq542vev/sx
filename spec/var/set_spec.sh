#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_var_set'
  Include ./sx.sh
  It '複数の変数を設定すること'
    When call sx_var_set v1=a v2=b
    The status should be success
    The variable v1 should equal "a"
    The variable v2 should equal "b"
  End

  It '値が指定されない場合、変数を未設定にすること'
    v1=a v2=b
    When call sx_var_set v1 v2
    The status should be success
    The variable v1 should be undefined
    The variable v2 should be undefined
  End

  It 'いずれかの変数が読み取り専用の場合に EX_NOPERM を返すこと'
    readonly r1_set=ro
    When call sx_var_set v3=c r1_set=err v4=d
    The status should equal 77
    The variable v3 should be undefined
    The variable v4 should be undefined
  End

  It '配列名を指定した場合、配列全体（要素含む）を削除すること'
    sx_arr_gen myarr x y
    When call sx_var_set myarr
    The status should be success
    The variable myarr should be undefined
    The variable myarr_len should be undefined
    The variable myarr_0 should be undefined
  End

  It '値に特殊文字（スペース）を含む変数を設定できること'
    When call sx_var_set "v=hello world"
    The variable v should equal "hello world"
  End

  It '値を空文字列に設定できること'
    v=old
    When call sx_var_set v=
    The variable v should equal ""
  End

  It '読み取り専用変数が混在している場合、全変数が未設定のままであること'
    readonly r1_set_ro=ro
    When call sx_var_set a_ro=1 r1_set_ro=err b_ro=2
    The status should equal 77
    The variable a_ro should be undefined
    The variable b_ro should be undefined
  End

  It '複数の変数を一度に設定し、すべて正しく設定されていること'
    When call sx_var_set a_batch=1 b_batch=2 c_batch=3
    The variable a_batch should equal 1
    The variable b_batch should equal 2
    The variable c_batch should equal 3
  End

  It '既存の変数の値を上書きできること'
    v_over=old
    When call sx_var_set v_over=new
    The variable v_over should equal "new"
  End
End
