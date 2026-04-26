Describe 'sx_var_list_ro'
  Include ./sx.sh
  It 'すべての読み取り専用変数名の一覧を返すこと'
    readonly MY_RO_VAR_1=ro
    When call sx_var_list_ro res
    The status should be success
    The variable res should include "MY_RO_VAR_1"
    # 一般的な環境変数の readonly も含まれる可能性がある
  End

  It '結果変数が読み取り専用の場合に EX_NOPERM を返すこと'
    readonly ro_res_list_ro="fixed"
    When call sx_var_list_ro ro_res_list_ro
    The status should equal 77
  End
End
