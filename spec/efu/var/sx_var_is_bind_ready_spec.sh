Describe 'sx_var_is_bind_ready -efu 環境検証'
  Include ./spec/support/run.sh

  setup_var_is_bind_ready_efu_fixture() {
    # 対象モジュールと準備用シェルを、ともに既定設定で初期化する。
    unset SX_CFG_SIG_ARR SX_CFG_SKIP_CHK SX_CFG_NUM_RANGE SX_CFG_SEP \
      SX_CFG_ARR_HOLE SX_CFG_ARR_REF
    sxtest_load ./build/modules/sx_var_is_bind_ready.sh
    # 各Exampleで未設定・空文字列を含む変数の初期状態を準備する。
    sxtest_run bir_e1 bir_e2 bir_re1 bir_re2 -- '
      sx_cfg_set
      sx_var_bind_init "bir_e1:bir_e2" "bir_re1:bir_re2"
    '
  }
  BeforeEach setup_var_is_bind_ready_efu_fixture

  It '準備済みの場合の正常動作'
    bir_efu_ok_case() {
      sx_var_is_bind_ready "bir_e1:bir_e2"
    }

    When run efu_run bir_efu_ok_case
    The status should be success
  End

  It '未準備の場合の失敗動作'
    bir_efu_ng_case() {
      unset bir_e3 bir_e4
      sx_var_is_bind_ready "bir_e3:bir_e4"
    }

    When run efu_run bir_efu_ng_case
    The status should equal 1
  End

  It '不正形式の場合の失敗動作'
    bir_efu_bad_case() {
      sx_var_is_bind_ready "bad-name"
    }

    When run efu_run bir_efu_bad_case
    The status should equal 64
  End

  It '読み取り専用変数を含む準備済み形式に成功を返すこと'
    bir_efu_ro_case() {
      readonly bir_re1 bir_re2
      sx_var_is_bind_ready "bir_re1:bir_re2"
    }

    When run efu_run bir_efu_ro_case
    The status should be success
  End
End
