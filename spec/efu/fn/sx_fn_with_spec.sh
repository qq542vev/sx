Describe 'sx_fn_with -efu 環境検証'
  sxtest_load ./build/modules/sx_fn_with.sh
  SX_CFG_SEP="--"

  It '正常動作'

    When run efu_run sx_fn_with 'cb=res="called with $1"' '--' cb "hello"
    The status should be success
  End
End
