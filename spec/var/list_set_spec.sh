Describe 'sx_var_list_set'
  Include ./sx.sh
  It '設定されているすべての変数の一覧を返す'
    MY_VAR_1=a MY_VAR_2=b
    When call sx_var_list_set res
    The status should be success
    The variable res should include "MY_VAR_1"
    The variable res should include "MY_VAR_2"
    The variable res should not start with " "
    The variable res should not end with " "
  End
End
