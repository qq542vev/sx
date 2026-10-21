Describe 'sx_var_is_empty -efu 環境検証'
  Include ./spec/support/library.sh sx_var_is_empty

  It '正常動作'
    a= b=

    When run efu_run sx_var_is_empty a b
    The status should be success
  End
End
