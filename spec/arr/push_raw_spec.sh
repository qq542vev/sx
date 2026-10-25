#!/bin/sh
# shellcheck shell=sh
# shellcheck disable=SC2286,SC2288 # Parameters の値はコマンドではない。
# shellcheck disable=SC2016,SC2154,SC2329 # 準備用コード、参照渡し、ShellSpec のコールバック。

Describe 'sx_arr_push_raw'
  Include ./spec/support/run.sh

  setup_push_raw() {
    unset SX_CFG_SIG_ARR SX_CFG_SKIP_CHK SX_CFG_NUM_RANGE SX_CFG_SEP \
      SX_CFG_ARR_UPDATE SX_CFG_ARR_HOLE SX_CFG_ARR_REF
    sxtest_load ./build/modules/sx_arr_push_raw.sh
    sxtest_run arr SX_SYS_REV -- 'sx_cfg_set; sx_arr_gen arr a b c'
    before_sig=$arr
    before_rev=$SX_SYS_REV
  }
  BeforeEach setup_push_raw

  Context '更新設定と検査省略'
    Parameters
      0 0
      0 1
      1 0
      1 1
    End

    It '要素を操作し、元配列の署名とカウンタを保持する'
      sxtest_run SX_CFG_ARR_UPDATE SX_CFG_SKIP_CHK -- 'sx_cfg_set "$@"' "ARR_UPDATE=$1" "SKIP_CHK=$2"
      When call sx_arr_push_raw arr x
      The status should be success
      The variable arr_len should equal 4
      The variable arr_3 should equal x
      The variable arr should equal "$before_sig"
      The variable SX_SYS_REV should equal "$before_rev"
      The variable SX_CFG_ARR_UPDATE should equal "$1"
    End
  End

  Context 'ARR_UPDATE を要求しない'
    Parameters
      unset
      invalid
    End

    It '未設定または不正でも操作できる'
      case "$1" in
        unset) unset SX_CFG_ARR_UPDATE;;
        invalid) SX_CFG_ARR_UPDATE=invalid;;
      esac
      When call sx_arr_push_raw arr x
      The status should be success
      The variable arr_len should equal 4
      The variable arr_3 should equal x
      The variable arr should equal "$before_sig"
      The variable SX_SYS_REV should equal "$before_rev"
      case "$1" in
        unset)
          The variable SX_CFG_ARR_UPDATE should be undefined
          ;;
        invalid)
          The variable SX_CFG_ARR_UPDATE should equal invalid
          ;;
      esac
    End
  End

  It '引数なしは64を返す'
    When call sx_arr_push_raw
    The status should equal 64
  End

  Context '配列名の検証'
    Parameters
      ''
      bad-name
    End

    It '無効な配列名は64を返す'
      When call sx_arr_push_raw "$1" x
      The status should equal 64
      The variable arr should equal "$before_sig"
    End
  End

  It '配列ではない対象は65を返す'
    scalar=value
    When call sx_arr_push_raw scalar x
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
      When call sx_arr_push_raw arr x
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
      When call sx_arr_push_raw arr x
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
      When call sx_arr_push_raw arr x
      The status should equal 78
      The variable arr should equal "$before_sig"
      The variable arr_len should equal 3
      The variable SX_SYS_REV should equal "$before_rev"
    End
  End

  It 'SKIP_CHK=1 は設定検査も省略する'
    SX_CFG_SKIP_CHK=1
    SX_CFG_NUM_RANGE=invalid
    When call sx_arr_push_raw arr x
    The status should be success
    The variable arr_len should equal 4
    The variable arr_3 should equal x
    The variable arr should equal "$before_sig"
  End

  It '値なしは長さとリビジョンを保持する'
    When call sx_arr_push_raw arr
    The status should be success
    The variable arr_len should equal 3
    The variable arr should equal "$before_sig"
    The variable SX_SYS_REV should equal "$before_rev"
  End

  It '空文字と引用符・改行を含む値を保持する'
    multiline='first
last'
    When call sx_arr_push_raw arr '' "it's" "$multiline"
    The status should be success
    The variable arr_len should equal 6
    The variable arr_3 should equal ''
    The variable arr_4 should equal "it's"
    The variable arr_5 should equal "$multiline"
    The variable arr should equal "$before_sig"
  End

  It '参照した入れ子配列をコピーし、穴は未設定要素にする'
    sxtest_run src SX_CFG_ARR_REF SX_CFG_ARR_HOLE SX_SYS_REV -- '
      SX_SYS_REV=$1
      sx_arr_gen src nested value
      sx_cfg_set ARR_REF=@ ARR_HOLE=hole
    ' "$SX_SYS_REV"
    When call sx_arr_push_raw arr @src hole ''
    The status should be success
    The variable arr_len should equal 6
    The variable arr_3_len should equal 2
    The variable arr_3_0 should equal nested
    The variable arr_3_1 should equal value
    The variable arr_4 should be undefined
    The variable arr_5 should equal ''
    The variable arr should equal "$before_sig"
  End
End
