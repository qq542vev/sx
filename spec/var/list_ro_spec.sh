Describe 'sx_var_list_ro'
  Include ./sx.sh
  It 'すべての読み取り専用変数の一覧を返す'
    readonly MY_RO_VAR_1=ro
    MY_RW_VAR_1=rw
    When call sx_var_list_ro res
    The status should be success
    The variable res should include "MY_RO_VAR_1"
    The variable res should not include "MY_RW_VAR_1"
    The variable res should not start with " "
    The variable res should not end with " "
  End
End
