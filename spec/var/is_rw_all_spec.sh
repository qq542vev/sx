#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_var_is_rw_all'
  Include ./spec/support/run.sh

  setup_var_is_rw_all_fixture() {
    # 対象モジュールと準備用シェルを、ともに既定設定で初期化する。
    unset SX_CFG_SIG_ARR SX_CFG_SKIP_CHK SX_CFG_NUM_RANGE SX_CFG_SEP \
      SX_CFG_ARR_HOLE SX_CFG_ARR_REF
    sxtest_load ./build/modules/sx_var_is_rw_all.sh
    # 各Exampleで配列の初期状態を準備する。
    sxtest_run myarr -- '
      sx_cfg_set
      sx_arr_gen myarr a b
    '
  }
  BeforeEach setup_var_is_rw_all_fixture

  It 'すべての変数が書き込み可能な場合に成功を返すこと'
    v1=1 v2=2
    When call sx_var_is_rw_all v1 v2
    The status should be success
  End

  It '読み取り専用変数が含まれる場合に失敗を返すこと'
    v1=1
    readonly v2_ro=2
    When call sx_var_is_rw_all v1 v2_ro
    The status should be failure
  End

  It '配列の要素が読み取り専用の場合に失敗を返すこと'
    readonly myarr_0
    When call sx_var_is_rw_all myarr
    The status should be failure
  End

  It '無効な変数名に対して EX_USAGE を返すこと'
    When call sx_var_is_rw_all "invalid-name"
    The status should equal 64
  End
End
