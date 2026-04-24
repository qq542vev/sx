Describe 'sx_var_is_ro'
  Include ./sx.sh
  It 'returns failure for writable variables'
    a=1
    When call sx_var_is_ro a
    The status should be failure
  End

  It 'returns success for readonly variables'
    readonly b_ro=2
    When call sx_var_is_ro b_ro
    The status should be success
  End

  It 'returns failure for non-existent variables'
    unset c_nonexistent
    When call sx_var_is_ro c_nonexistent
    The status should be failure
  End
End
