Describe 'sx_arr_rquote -efu 環境検証'
  Include ./spec/support/run.sh

  setup_arr_rquote_efu_fixture() {
    # 対象モジュールと準備用シェルを、ともに既定設定で初期化する。
    unset SX_CFG_SIG_ARR SX_CFG_SKIP_CHK SX_CFG_NUM_RANGE SX_CFG_SEP \
      SX_CFG_ARR_UPDATE SX_CFG_ARR_HOLE SX_CFG_ARR_REF
    sxtest_load ./build/modules/sx_arr_rquote.sh
    sxtest_run arr1 -- '
      sx_cfg_set
      sx_arr_gen arr1 a b c
    '
  }
  BeforeEach setup_arr_rquote_efu_fixture

  It '正常動作'
    When run efu_run sx_arr_rquote result arr1
    The status should be success
  End
End
