#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_var_dump'
  Include ./spec/support/run.sh

  setup_var_dump_fixture() {
    # 対象モジュールと準備用シェルを、ともに既定設定で初期化する。
    unset SX_CFG_SIG_ARR SX_CFG_SKIP_CHK SX_CFG_NUM_RANGE SX_CFG_SEP \
      SX_CFG_ARR_HOLE SX_CFG_ARR_REF
    sxtest_load ./build/modules/sx_var_dump.sh
    # 各Exampleで配列の初期状態を準備する。
    sxtest_run myarr -- '
      sx_cfg_set
      sx_arr_gen myarr item1
    '
  }
  BeforeEach setup_var_dump_fixture

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
    When call sx_var_dump res myarr
    The status should be success
    # 各行が改行で終わるため、line 指定で個別に検証可能
    # myarrはBeforeEachのsxtest_runで準備する。
    # shellcheck disable=SC2154
    The line 1 of variable res should equal "myarr='${myarr}'"
    The line 2 of variable res should equal "myarr_len='1'"
    The line 3 of variable res should equal "myarr_0='item1'"
  End

  It '未設定の変数の場合に unset 命令を取得すること'
    unset undef_var
    When call sx_var_dump res undef_var
    The status should be success
    The variable res should equal "unset -v undef_var${SX_STR_LF}"
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
