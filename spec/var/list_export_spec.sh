#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_var_list_export'
  sxtest_load ./build/modules/sx_var_list_export.sh

  It 'すべてのエクスポート属性付き変数名の一覧を返すこと'
    export MY_EXPORT_VAR_1=exported
    MY_NON_EXPORT_VAR_1=not_exported
    res=
    When call sx_var_list_export res
    The status should be success
    The variable res should include "MY_EXPORT_VAR_1"
    The variable res should not include "MY_NON_EXPORT_VAR_1"
    # 一般的な環境変数の export も含まれる可能性がある
  End

  It 'バインド形式で分配できること'
    export MY_EXPORT_VAR_2=exported
    export MY_EXPORT_VAR_3=exported
    h1=
    h2=
    When call sx_var_list_export "h1:h2"
    The status should be success
    # 環境変数が多数存在するため、テスト変数の分配位置は不定
    # 結合して確認する
    combined="${h1} ${h2}"
    The variable combined should include "MY_EXPORT_VAR_2"
    The variable combined should include "MY_EXPORT_VAR_3"
  End

  It '引数が未指定の場合に EX_USAGE を返すこと'
    When call sx_var_list_export
    The status should equal 64
  End

  It '結果変数が読み取り専用の場合に EX_NOPERM を返すこと'
    readonly ro_res_list_export="fixed"
    When call sx_var_list_export ro_res_list_export
    The status should equal 77
  End

  It 'SX_CFG_NUM_RANGE が不正な場合に EX_CONFIG を返すこと'
    SX_CFG_NUM_RANGE=bad
    When call sx_var_list_export res
    The status should equal 78
  End
End
