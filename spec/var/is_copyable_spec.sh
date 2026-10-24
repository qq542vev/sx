#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_var_is_copyable'
  Include ./spec/support/run.sh

  setup_var_is_copyable_fixture() {
    # 対象モジュールと準備用シェルを、ともに既定設定で初期化する。
    unset SX_CFG_SIG_ARR SX_CFG_SKIP_CHK SX_CFG_NUM_RANGE SX_CFG_SEP \
      SX_CFG_ARR_UPDATE SX_CFG_ARR_HOLE SX_CFG_ARR_REF
    sxtest_load ./build/modules/sx_var_is_copyable.sh
    # 各Exampleで配列の初期状態を準備する。
    sxtest_run myarr -- '
      sx_cfg_set
      sx_arr_gen myarr a b
    '
  }
  BeforeEach setup_var_is_copyable_fixture

  It 'コピー先の変数がすべて書き込み可能な場合に成功を返すこと'
    v1=a v2=b v3=c
    When call sx_var_is_copyable "v1-v2-v3"
    The status should be success
  End

  It 'コピー先に読み取り専用変数が含まれる場合に失敗を返すこと'
    v1=a
    readonly v2_ro=b
    When call sx_var_is_copyable "v1-v2_ro"
    The status should be failure
  End

  It '配列の要素が読み取り専用の場合に失敗を返すこと'
    readonly myarr_1
    When call sx_var_is_copyable "src-myarr"
    The status should be failure
  End

  It '無効な連鎖式に対して EX_USAGE を返すこと'
    When call sx_var_is_copyable "a+b"
    The status should equal 64
  End

  It 'コピー先と接頭辞を共有する読み取り専用変数がある場合に失敗を返すこと'
    v1=a v2=b
    readonly v2_ro=c
    When call sx_var_is_copyable "v1-v2"
    The status should be failure
  End
End
