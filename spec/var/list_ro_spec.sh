#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_var_list_ro'
  Include ./sx.sh

  It 'すべての読み取り専用変数名の一覧を返すこと'
    readonly MY_RO_VAR_1=ro
    MY_WR_VAR_1=rw
    res=
    When call sx_var_list_ro res
    The status should be success
    The variable res should include "MY_RO_VAR_1"
    The variable res should not include "MY_WR_VAR_1"
    # 一般的な環境変数の readonly も含まれる可能性がある
  End

  It 'バインド形式で分配できること'
    readonly MY_RO_VAR_2=ro
    readonly MY_RO_VAR_3=ro
    h1=
    h2=
    When call sx_var_list_ro "h1:h2"
    The status should be success
    The variable h1 should include "MY_RO_VAR_2"
    The variable h2 should include "MY_RO_VAR_3"
  End

  It '引数が未指定の場合に EX_USAGE を返すこと'
    When call sx_var_list_ro
    The status should equal 64
  End

  It '結果変数が読み取り専用の場合に EX_NOPERM を返すこと'
    readonly ro_res_list_ro="fixed"
    When call sx_var_list_ro ro_res_list_ro
    The status should equal 77
  End

  It 'SX_CFG_NUM_RANGE が不正な場合に EX_CONFIG を返すこと'
    SX_CFG_NUM_RANGE=bad
    When call sx_var_list_ro res
    The status should equal 78
  End
End