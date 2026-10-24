# shellcheck disable=SC2016 # CMD内の変数は準備用シェルで展開する。
Describe 'sx_arr_bind -efu 環境検証'
  Include ./spec/support/run.sh
  sxtest_load ./build/modules/sx_arr_bind.sh

  It '正常動作'
    br=
    cr=
    When run efu_run sx_arr_bind br cr "a:b:c" v1 v2
    The status should be success
  End

  It 'バインドが空で対象が残っている場合に 1 を返すこと'
    br=
    cr=
    When run efu_run sx_arr_bind br cr "" v1
    The status should equal 1
  End

  It '64ビットレンジでの正常動作'
    Skip if 'ホストの算術展開が64bit未満のため' arith_lt64
    br=
    cr=
    run64() {
      sxtest_run SX_CFG_NUM_RANGE SX_SYS_NUM_QM SX_SYS_NUM_ZR -- 'sx_cfg_set "$@"' NUM_RANGE=64
      sx_arr_bind br cr "0/a" p1 p2
    }
    When run efu_run run64
    The status should be success
  End
End
