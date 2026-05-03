#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_var_dump'
  Include ./sx.sh

  It '変数の状態を代入式形式で取得すること（末尾改行あり）'
    v1="hello world"
    When call sx_var_dump res v1
    The status should be success
    The variable res should equal "v1='hello world'${SX_STR_LF}"
  End

  It '複数の変数の状態を取得すること'
    v1=a v2=b
    When call sx_var_dump res v1 v2
    The status should be success
    The variable res should equal "v1='a'${SX_STR_LF}v2='b'${SX_STR_LF}"
  End

  It '配列の状態を関連要素を含めて取得すること'
    sx_arr_gen myarr item1
    When call sx_var_dump res myarr
    The status should be success
    # 各行が改行で終わるため、line 指定で個別に検証可能
    The line 1 of variable res should equal "myarr='${myarr}'"
    The line 2 of variable res should equal "myarr_len='1'"
    The line 3 of variable res should equal "myarr_0='item1'"
  End

  It '未設定の変数の場合に unset 命令を取得すること'
    unset undef_var
    When call sx_var_dump res undef_var
    The status should be success
    The variable res should equal "unset undef_var${SX_STR_LF}"
  End

  It '結果変数が読み取り専用の場合に EX_NOPERM を返すこと'
    readonly r1_dump=ro
    When call sx_var_dump r1_dump v1
    The status should equal 77
  End

  It '無効な変数名が指定された場合に EX_USAGE を返すこと'
    When call sx_var_dump res "1invalid"
    The status should equal 64
  End
End
