Describe 'sx_arr_pop -efu 環境検証'
  Include ./spec/support/setup.sh

  setup_arr_pop_efu_fixture() {
    # 対象モジュールと準備用シェルを、ともに既定設定で初期化する。
    unset SX_CFG_SIG_ARR SX_CFG_SKIP_CHK SX_CFG_NUM_RANGE SX_CFG_SEP \
      SX_CFG_ARR_UPDATE SX_CFG_ARR_HOLE SX_CFG_ARR_REF
    Include ./spec/support/library.sh sx_arr_pop
    # 各Exampleで配列の初期状態を準備する。
    sxtest_setup myarr -- '
      sx_cfg_set
      sx_arr_gen myarr a b c
    '
  }
  BeforeEach setup_arr_pop_efu_fixture

  It '正常動作'
    When run efu_run sx_arr_pop x: myarr
    The status should be success
  End

  It '要素不足で 1 を返すこと'
    When run efu_run sx_arr_pop x:y:z:w: myarr
    The status should equal 1
  End
End
