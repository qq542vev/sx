Describe 'sx_var_list_ro -efu 環境検証'
  Include ./sx.sh

  It '正常動作'
    my_ro_efu=1; readonly my_ro_efu

    When run efu_run sx_var_list_ro res
    The status should be success
  End

  It 'バインド形式で成功すること'
    When run efu_run sx_var_list_ro "h1:h2"
    The status should be success
  End

  It '引数が未指定の場合に EX_USAGE を返すこと'
    When run efu_run sx_var_list_ro
    The status should equal 64
  End

  It '結果変数が読み取り専用の場合に EX_NOPERM を返すこと'
    ro_res_efu=1; readonly ro_res_efu

    When run efu_run sx_var_list_ro ro_res_efu
    The status should equal 77
  End
End