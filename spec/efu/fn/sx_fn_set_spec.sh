Describe 'sx_fn_set -efu 環境検証'
  Include ./spec/support/library.sh sx_fn_set

  It '正常動作'
    When run efu_run sx_fn_set "f1=echo 1"
    The status should be success
  End
End
