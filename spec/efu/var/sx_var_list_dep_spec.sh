Describe 'sx_var_list_dep -efu 環境検証'
  Include ./spec/support/library.sh spec/efu/var/sx_var_list_dep_spec.sh sx_var_list_dep

  It '正常動作'

    When run efu_run sx_var_list_dep result myarr v1
    The status should be success
  End
End
