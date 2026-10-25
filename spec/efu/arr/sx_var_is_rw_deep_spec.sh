Describe 'sx_var_is_rw_deep -efu 環境検証'
  Include ./spec/support/run.sh

  load_var_is_rw_deep_efu_module() {
    # 対象モジュールと準備用シェルを、ともに既定設定で初期化する。
    unset SX_CFG_SIG_ARR SX_CFG_SKIP_CHK SX_CFG_NUM_RANGE SX_CFG_SEP \
      SX_CFG_ARR_HOLE SX_CFG_ARR_REF
    sxtest_load ./build/modules/sx_var_is_rw_deep.sh
  }
  BeforeEach load_var_is_rw_deep_efu_module

  It '正常動作'
    sxtest_run arr -- '
      sx_cfg_set
      sx_arr_gen arr a b c
    '

    When run efu_run sx_var_is_rw_deep arr
    The status should be success
  End

  It '読み取り専用要素を検出できること'
    arr_len=1 arr_0=a
    readonly arr_0

    When run efu_run sx_var_is_rw_deep arr
    The status should be failure
  End
End
