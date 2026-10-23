#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_var_swap'
  Include ./spec/support/run.sh

  setup_var_swap_fixture() {
    # 対象モジュールと準備用シェルを、ともに既定設定で初期化する。
    unset SX_CFG_SIG_ARR SX_CFG_SKIP_CHK SX_CFG_NUM_RANGE SX_CFG_SEP \
      SX_CFG_ARR_UPDATE SX_CFG_ARR_HOLE SX_CFG_ARR_REF
    Include ./spec/support/library.sh sx_var_swap
    # 各Exampleで配列の初期状態を準備する。
    sxtest_run arr1 arr2 -- '
      sx_cfg_set
      sx_arr_gen arr1 a
      sx_arr_gen arr2 b
    '
  }
  BeforeEach setup_var_swap_fixture

  It '右方向に値を回転（v1-v2-v3 -> v3 v1 v2）させること'
    v1=AAA v2=BBB v3=CCC
    When call sx_var_swap v1-v2-v3
    The status should be success
    The variable v1 should equal "CCC"
    The variable v2 should equal "AAA"
    The variable v3 should equal "BBB"
  End

  It '左方向に値を回転（v1=v2=v3 -> v2 v3 v1）させること'
    v1=AAA v2=BBB v3=CCC
    When call sx_var_swap v1=v2=v3
    The status should be success
    The variable v1 should equal "BBB"
    The variable v2 should equal "CCC"
    The variable v3 should equal "AAA"
  End

  It '配列を回転できること'
    When call sx_var_swap arr1-arr2
    The status should be success
    The variable arr1_0 should equal "b"
    The variable arr2_0 should equal "a"
  End

  It '変数が読み取り専用の場合に EX_NOPERM を返すこと'
    v1=a
    readonly v2_ro=b
    When call sx_var_swap v1-v2_ro
    The status should equal 77
  End

  It '無効な連鎖式に対して EX_USAGE を返すこと'
    When call sx_var_swap "a+b"
    The status should equal 64
  End

  It '引数が1つの場合は何もしないこと'
    v1=AAA
    When call sx_var_swap v1
    The status should be success
    The variable v1 should equal "AAA"
  End

  It '交換対象と接頭辞を共有する読み取り専用変数がある場合に EX_NOPERM を返すこと'
    v1=a v2=b
    readonly v2_ro=c
    When call sx_var_swap v1-v2
    The status should equal 77
    The variable v1 should equal "a"
    The variable v2 should equal "b"
  End
End
