Describe 'sx_arg_reach -efu 環境検証'
  Include ./spec/support/run.sh
  sxtest_load ./build/modules/sx_arg_reach.sh

  It '正常動作'
    When run efu_run sx_arg_reach efu_cb_true 'a b' '' "c'd"
    The status should be success
  End

  Context '多倍長経路'
    Parameters
      0
      1
    End

    It '検証の有無によらず-efu下で全要素を処理する'
      sxtest_run SX_CFG_SKIP_CHK -- 'sx_cfg_set "$@"' "SKIP_CHK=$1"
      __sx_num_is_int_fit_dec() { return 1; }
      __sx_num_add1_arith() { return 64; }
      When run efu_run sx_arg_reach efu_cb_true 'a b' '' "c'd"
      The status should be success
    End

    It '-efu下でコールバックの失敗ステータスを返す'
      sxtest_run SX_CFG_SKIP_CHK -- 'sx_cfg_set "$@"' "SKIP_CHK=$1"
      __sx_num_is_int_fit_dec() { return 1; }
      __sx_num_add1_arith() { return 64; }
      cb_stop() { case "$2" in 2) return 77;; esac; return 0; }
      When run efu_run sx_arg_reach cb_stop a b c
      The status should equal 77
    End
  End
End
