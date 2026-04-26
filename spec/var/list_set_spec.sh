Describe 'sx_var_list_set'
  Include ./sx.sh

  It '設定されているすべての変数名の一覧を返すこと'
    MY_VAR_1=a MY_VAR_2=b res=
    When call sx_var_list_set res
    The status should be success
    The variable res should include "MY_VAR_1"
    The variable res should include "MY_VAR_2"
    The variable res should include "res"
  End

  It '結果変数が読み取り専用の場合に EX_NOPERM を返すこと'
    readonly ro_res_list_set="fixed"
    When call sx_var_list_set ro_res_list_set
    The status should equal 77
  End

  It 'IFS が読み取り専用の場合に EX_NOPERM を返すこと'
    test_ro_ifs() {
      readonly IFS
      sx_var_list_set res
    }
    When run test_ro_ifs
    The status should equal 77
  End
End
