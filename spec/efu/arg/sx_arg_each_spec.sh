# shellcheck shell=sh disable=SC2329
# コールバックと検証用の差し替え関数はShellSpec経由で間接的に呼び出される。

Describe 'sx_arg_each -efu 環境検証'
  Include ./spec/support/prepare.sh
  Include ./spec/support/library.sh sx_arg_each

  Context '多倍長経路'
    Parameters
      0
      1
    End

    It '検証の有無によらず-efu下で全要素を処理する'
      sx_test_setup sx_cfg_set "SKIP_CHK=$1"
      __sx_num_is_int_fit_dec() { return 1; }
      __sx_num_add1_arith() { return 64; }
      When run efu_run sx_arg_each efu_cb_true 'a b' '' "c'd"
      The status should be success
    End

    It '-efu下でコールバックの失敗ステータスを返す'
      sx_test_setup sx_cfg_set "SKIP_CHK=$1"
      __sx_num_is_int_fit_dec() { return 1; }
      __sx_num_add1_arith() { return 64; }
      cb_stop() { case "$2" in 2) return 77;; esac; return 0; }
      When run efu_run sx_arg_each cb_stop a b c
      The status should equal 77
    End
  End

  It '引数個数が安全範囲外でも-efu下で成功する'
    __sx_num_is_nat0_safe() { return 1; }
    When run efu_run sx_arg_each efu_cb_true a b c
    The status should be success
  End

  It '正常動作'

    When run efu_run sx_arg_each efu_cb_true a b c
    The status should be success
  End
End
