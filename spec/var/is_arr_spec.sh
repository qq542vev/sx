#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_var_is_arr'
  Include ./spec/support/run.sh

  setup_is_arr_fixture() {
    # 対象モジュールと準備用シェルを、ともに既定設定で初期化する。
    unset SX_CFG_SIG_ARR SX_CFG_SKIP_CHK SX_CFG_NUM_RANGE SX_CFG_SEP \
      SX_CFG_ARR_UPDATE SX_CFG_ARR_HOLE SX_CFG_ARR_REF
    sxtest_load ./build/modules/sx_var_is_arr.sh
    sxtest_run myarr -- '
      sx_cfg_set
      sx_arr_gen myarr a b
    '
  }
  BeforeEach setup_is_arr_fixture

  It 'sx配列に対して成功を返すこと'
    When call sx_var_is_arr myarr
    The status should be success
  End

  It '通常の変数に対して失敗を返すこと'
    regular_var="val"
    When call sx_var_is_arr regular_var
    The status should be failure
  End
End
