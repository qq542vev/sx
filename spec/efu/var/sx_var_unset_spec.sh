Describe 'sx_var_unset -efu 環境検証'
  Include ./spec/support/library.sh spec/efu/var/sx_var_unset_spec.sh sx_var_unset

  It '正常動作'

    When run efu_run sx_var_unset a
    The status should be success
  End
End
