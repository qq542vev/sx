# shellcheck shell=sh disable=SC2329
# コールバックと検証用の差し替え関数はShellSpec経由で間接的に呼び出される。

Describe 'sx_arg_map -efu 環境検証'
  Include ./sx.sh

  Context '多倍長経路'
    Parameters
      0
      1
    End

    It '検証の有無によらず-efu下で全要素を変換する'
      sx_cfg_set "SKIP_CHK=$1"
      __sx_num_is_int_fit_dec() { return 1; }
      __sx_num_add1_arith() { return 64; }
      When run efu_run sx_arg_map res efu_cb_set3 'a b' '' "c'd"
      The status should be success
    End

    It '-efu下でスキップとバインド枯渇を扱う'
      sx_cfg_set "SKIP_CHK=$1"
      __sx_num_is_int_fit_dec() { return 1; }
      __sx_num_add1_arith() { return 64; }
      cb() { case "$2" in skip) return 0;; esac; __sx_var_set "${1}=${3}"; }
      When run efu_run sx_arg_map '2res:' cb skip a b c
      The status should be success
    End

    It '-efu下で最初の失敗ステータスを返す'
      sx_cfg_set "SKIP_CHK=$1"
      __sx_num_is_int_fit_dec() { return 1; }
      __sx_num_add1_arith() { return 64; }
      cb() { case "$3" in 2) return 77;; esac; __sx_var_set "${1}=${3}"; }
      When run efu_run sx_arg_map res cb a b c
      The status should equal 77
    End
  End

  It '正常動作'

    When run efu_run sx_arg_map res efu_cb_set3 a b c
    The status should be success
  End
End
