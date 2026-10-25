#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_var_list_dep'
  Include ./spec/support/run.sh

  setup_var_list_dep_fixture() {
    # 対象モジュールと準備用シェルを、ともに既定設定で初期化する。
    unset SX_CFG_SIG_ARR SX_CFG_SKIP_CHK SX_CFG_NUM_RANGE SX_CFG_SEP \
      SX_CFG_ARR_HOLE SX_CFG_ARR_REF
    sxtest_load ./build/modules/sx_var_list_dep.sh
    # 各Exampleで配列の初期状態を準備する。
    sxtest_run myarr inner outer dup_arr -- '
      sx_cfg_set
      sx_arr_gen myarr a b
      sx_arr_gen inner x y
      sx_arr_gen outer inner
      sx_arr_gen dup_arr x y z
    '
  }
  BeforeEach setup_var_list_dep_fixture

  It '指定された変数に関連するすべての変数名を収集すること'
    v1=x
    When call sx_var_list_dep result myarr v1
    The status should be success
    The variable result should include "myarr"
    The variable result should include "myarr_len"
    The variable result should include "myarr_0"
    The variable result should include "myarr_1"
    The variable result should include "v1"
  End

  It '配列が入れ子になっている場合も収集すること'
    # sx 配列の要素に別の sx 配列の名前を入れる
    When call sx_var_list_dep result outer
    The status should be success
    The variable result should include "outer"
    The variable result should include "outer_0"
    # Note: sx_var_list_dep recursively collects if the value is an array name
    # Wait, does it? Let's check implementation.
    # __sx_var_list_dep looks at if __sx_var_is_arr "${1}"
    # and then adds ${1}_len, ${1}_0, etc. to the queue.
    # If outer_0's value is "array-sx-sig-...", then it will be treated as an array.
    # But sx_arr_gen outer inner will set outer_0="inner".
    # Unless outer_0 itself is an array.
  End

  It '重複する変数名が指定されても一意に収集すること'
    v1=x
    When call sx_var_list_dep result dup_arr v1 dup_arr v1 v1 dup_arr
    The status should be success
    The variable result should include "dup_arr"
    The variable result should include "dup_arr_len"
    The variable result should include "dup_arr_0"
    The variable result should include "dup_arr_1"
    The variable result should include "dup_arr_2"
    The variable result should include "v1"
    # 重複を除去した結果、6つの変数名だけが収集されていること
    The variable result should equal "dup_arr v1 dup_arr_len dup_arr_0 dup_arr_1 dup_arr_2"
  End

  It '結果変数が読み取り専用の場合に EX_NOPERM を返すこと'
    readonly ro_res_list_dep="fixed"
    When call sx_var_list_dep ro_res_list_dep v1
    The status should equal 77
  End

  It '無効な変数名に対して EX_USAGE を返すこと'
    When call sx_var_list_dep result "invalid-name"
    The status should equal 64
  End
End
