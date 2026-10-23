Describe 'sx_var_ubind -efu 環境検証'
  Include ./spec/support/run.sh

  load_var_ubind_efu_module() {
    # 対象モジュールと準備用シェルを、ともに既定設定で初期化する。
    unset SX_CFG_SIG_ARR SX_CFG_SKIP_CHK SX_CFG_NUM_RANGE SX_CFG_SEP \
      SX_CFG_ARR_UPDATE SX_CFG_ARR_HOLE SX_CFG_ARR_REF
    Include ./spec/support/library.sh sx_var_ubind
  }
  BeforeEach load_var_ubind_efu_module

  It '正常動作'
    sxtest_run v1 v2 rest -- '
      sx_cfg_set
      sx_var_bind_init "v1:v2:rest"
    '
    efu_ubind_ok() {
      sx_var_ubind res "v1:v2:rest" "val1" "val2" "val3"
    }

    When run efu_run efu_ubind_ok
    The status should be success
  End

  It 'バインド先の枯渇で 1 を返すこと'
    sxtest_run v1 -- '
      sx_cfg_set
      sx_var_bind_init "v1:"
    '
    efu_ubind_exhaust() {
      sx_var_ubind res "v1:" "a" "b"
    }

    When run efu_run efu_ubind_exhaust
    The status should equal 1
  End

  It '@name への分配が正常動作すること'
    sxtest_run x eu_arr -- '
      sx_cfg_set
      sx_var_bind_init "x:@eu_arr"
    '
    efu_ubind_arr() {
      sx_var_ubind res "x:@eu_arr" "v1" "v2" "v3"
    }

    When run efu_run efu_ubind_arr
    The status should be success
  End

  It '空結果変数で残りを破棄できること'
    sxtest_run e1 erest -- '
      sx_cfg_set
      sx_var_bind_init "e1:erest"
    '
    efu_ubind_empty() {
      sx_var_ubind "" "e1:erest" "a b"
    }

    When run efu_run efu_ubind_empty
    The status should be success
  End

  It '空結果変数で枯渇時に 1 を返すこと'
    sxtest_run e3 -- '
      sx_cfg_set
      sx_var_bind_init "e3:"
    '
    efu_ubind_empty_exhaust() {
      sx_var_ubind "" "e3:" "a" "b"
    }

    When run efu_run efu_ubind_empty_exhaust
    The status should equal 1
  End
End
