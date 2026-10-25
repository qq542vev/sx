#!/bin/sh
# shellcheck shell=sh
# shellcheck disable=SC2286,SC2288 # Parameters の値はコマンドではない。
# shellcheck disable=SC2016,SC2154,SC2329 # 準備用コード、参照渡し、ShellSpec のコールバック。

Describe 'sx_arr_pop_raw'
  Include ./spec/support/run.sh

  setup_pop_raw() {
    unset SX_CFG_SIG_ARR SX_CFG_SKIP_CHK SX_CFG_NUM_RANGE SX_CFG_SEP \
      SX_CFG_ARR_HOLE SX_CFG_ARR_REF
    sxtest_load ./build/modules/sx_arr_pop_raw.sh
    sxtest_run arr SX_SYS_REV -- 'sx_cfg_set; sx_arr_gen arr a b c'
    before_sig=$arr
    before_rev=$SX_SYS_REV
  }
  BeforeEach setup_pop_raw

  Context '検査省略の有無'
    Parameters
      0
      1
    End

    It '要素を操作し、元配列の署名とカウンタを保持する'
      sxtest_run SX_CFG_SKIP_CHK -- 'sx_cfg_set "$@"' "SKIP_CHK=$1"
      When call sx_arr_pop_raw out: arr
      The status should be success
      The variable arr_len should equal 2
      The variable out should equal c
      The variable arr_2 should be undefined
      The variable arr should equal "$before_sig"
      The variable SX_SYS_REV should equal "$before_rev"
    End
  End

  It '引数なしは64を返す'
    When call sx_arr_pop_raw
    The status should equal 64
  End

  Context '配列名の検証'
    Parameters
      ''
      bad-name
    End

    It '無効な配列名は64を返す'
      When call sx_arr_pop_raw out: "$1"
      The status should equal 64
      The variable arr should equal "$before_sig"
    End
  End

  It '配列ではない対象は65を返す'
    scalar=value
    When call sx_arr_pop_raw out: scalar
    The status should equal 65
    The variable scalar should equal value
  End

  Context '配下も含む書込可否'
    Parameters
      arr
      arr_len
      arr_1
      arr_1_nested
    End

    It 'readonly があれば77を返し、何も変更しない'
      readonly "$1"
      When call sx_arr_pop_raw out: arr
      The status should equal 77
      The variable arr should equal "$before_sig"
      The variable arr_len should equal 3
      The variable arr_1 should equal b
      The variable SX_SYS_REV should equal "$before_rev"
    End
  End

  Context '必要設定の未設定'
    Parameters
      SX_CFG_SIG_ARR
      SX_CFG_NUM_RANGE
      SX_CFG_ARR_HOLE
      SX_CFG_ARR_REF
    End

    It '変更前に78を返す'
      unset "$1"
      When call sx_arr_pop_raw out: arr
      The status should equal 78
      The variable arr should equal "$before_sig"
      The variable arr_len should equal 3
      The variable arr_1 should equal b
      The variable SX_SYS_REV should equal "$before_rev"
    End
  End

  Context '必要設定の不正値'
    Parameters
      SX_CFG_SIG_ARR=
      SX_CFG_NUM_RANGE=invalid
    End

    It '変更前に78を返す'
      export "${1?}"
      When call sx_arr_pop_raw out: arr
      The status should equal 78
      The variable arr should equal "$before_sig"
      The variable arr_len should equal 3
      The variable SX_SYS_REV should equal "$before_rev"
    End
  End

  It 'SKIP_CHK=1 は設定検査も省略する'
    SX_CFG_SKIP_CHK=1
    SX_CFG_NUM_RANGE=invalid
    When call sx_arr_pop_raw out: arr
    The status should be success
    The variable arr_len should equal 2
    The variable out should equal c
    The variable arr_2 should be undefined
    The variable arr should equal "$before_sig"
  End

  Context 'bind の検証'
    Parameters
      '@out'
      bad-name:
    End

    It '無効な bind は64を返す'
      When call sx_arr_pop_raw "$1" arr
      The status should equal 64
      The variable arr_len should equal 3
      The variable arr should equal "$before_sig"
    End
  End

  It '元配列の指定がなければ64を返す'
    When call sx_arr_pop_raw out:
    The status should equal 64
  End

  Context '分配先の書込可否'
    Parameters
      out
      out_len
    End

    It 'readonly の分配先は77を返す'
      readonly "$1"
      When call sx_arr_pop_raw 2out: arr
      The status should equal 77
      The variable arr_len should equal 3
      The variable arr should equal "$before_sig"
      The variable SX_SYS_REV should equal "$before_rev"
    End
  End

  It '複数スカラーへの分配と破棄を末尾から行う'
    When call sx_arr_pop_raw x:1:y: arr
    The status should be success
    The variable x should equal c
    The variable y should equal a
    The variable arr_len should equal 0
    The variable arr_0 should be undefined
    The variable arr_1 should be undefined
    The variable arr_2 should be undefined
    The variable arr should equal "$before_sig"
    The variable SX_SYS_REV should equal "$before_rev"
  End

  Context '要素不足'
    Parameters
      0
      1
    End

    It '検査省略の有無にかかわらず1を返し、元配列と分配先を保持する'
      sxtest_run SX_CFG_SKIP_CHK -- 'sx_cfg_set "$@"' "SKIP_CHK=$1"
      x=original
      When call sx_arr_pop_raw x:3out: arr
      The status should equal 1
      The variable x should equal original
      The variable out should be undefined
      The variable arr_len should equal 3
      The variable arr_0 should equal a
      The variable arr_1 should equal b
      The variable arr_2 should equal c
      The variable arr should equal "$before_sig"
      The variable SX_SYS_REV should equal "$before_rev"
    End
  End

  It '末尾のコロンがない bind は受理し、要素不足の1を返す'
    When call sx_arr_pop_raw out arr
    The status should equal 1
    The variable out should be undefined
    The variable arr_len should equal 3
  End

  It '空配列からの取り出しは1を返す'
    sxtest_run arr SX_SYS_REV -- 'SX_SYS_REV=$1; sx_arr_gen arr' "$SX_SYS_REV"
    empty_sig=$arr
    When call sx_arr_pop_raw out: arr
    The status should equal 1
    The variable out should be undefined
    The variable arr_len should equal 0
    The variable arr should equal "$empty_sig"
  End

  Context '分配先配列のリビジョン'

    It '元配列の署名を保持し、分配先配列には新しいリビジョンを発行する'
      When call sx_arr_pop_raw 2out: arr
      The status should be success
      The variable out should equal "${SX_CFG_SIG_ARR}:$before_rev"
      The variable out_len should equal 2
      The variable out_0 should equal c
      The variable out_1 should equal b
      The variable arr_len should equal 1
      The variable arr should equal "$before_sig"
      The variable SX_SYS_REV should equal "$((before_rev + 1))"
    End
  End
End
