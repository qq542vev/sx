#!/bin/sh
# shellcheck shell=sh
# ShellSpec の Parameters と動的な配列要素を検証する。
# shellcheck disable=SC2154

Describe '配列操作とリビジョン更新の分離'
  Include ./spec/support/library.sh spec/arr/raw_spec.sh SX_CFG_ARR_HOLE SX_CFG_ARR_REF SX_CFG_ARR_UPDATE SX_CFG_SIG_ARR SX_SYS_REV __sx_arr_pop_raw __sx_arr_push_raw __sx_arr_splice_raw sx_arr_gen sx_arr_pop sx_arr_push sx_arr_splice sx_cfg_set sx_var_bind sx_var_bind_init sx_var_ubind

  Context 'raw の元配列は更新しない'
    Parameters
      0
      1
    End

    It 'push_raw は設定にかかわらず末尾へ追加し署名とカウンタを保持する'
      sx_cfg_set "ARR_UPDATE=$1"
      sx_arr_gen arr a
      before_sig=$arr
      before_rev=$SX_SYS_REV
      When call __sx_arr_push_raw arr b ''
      The status should be success
      The variable arr_len should equal 3
      The variable arr_1 should equal b
      The variable arr_2 should equal ''
      The variable arr should equal "$before_sig"
      The variable SX_SYS_REV should equal "$before_rev"
      The variable SX_CFG_ARR_UPDATE should equal "$1"
    End

    It 'splice_raw は設定にかかわらず挿入・削除し署名とカウンタを保持する'
      sx_cfg_set "ARR_UPDATE=$1"
      sx_arr_gen arr a b c
      before_sig=$arr
      before_rev=$SX_SYS_REV
      When call __sx_arr_splice_raw arr 1 1 x y
      The status should be success
      The variable arr_len should equal 4
      The variable arr_0 should equal a
      The variable arr_1 should equal x
      The variable arr_2 should equal y
      The variable arr_3 should equal c
      The variable arr should equal "$before_sig"
      The variable SX_SYS_REV should equal "$before_rev"
      The variable SX_CFG_ARR_UPDATE should equal "$1"
    End

    It 'pop_raw は設定にかかわらず末尾を取り出し元の署名とカウンタを保持する'
      sx_cfg_set "ARR_UPDATE=$1"
      sx_arr_gen arr a b c
      before_sig=$arr
      before_rev=$SX_SYS_REV
      When call __sx_arr_pop_raw x: arr
      The status should be success
      The variable x should equal c
      The variable arr_len should equal 2
      The variable arr_2 should be undefined
      The variable arr should equal "$before_sig"
      The variable SX_SYS_REV should equal "$before_rev"
      The variable SX_CFG_ARR_UPDATE should equal "$1"
    End
  End

  It 'raw でも参照と穴の解釈を維持する'
    sx_arr_gen src nested value
    sx_arr_gen arr head
    sx_cfg_set 'ARR_REF=@' 'ARR_HOLE=hole'
    before_sig=$arr
    before_rev=$SX_SYS_REV
    When call __sx_arr_push_raw arr '@src' hole ''
    The status should be success
    The variable arr_len should equal 4
    The variable arr_1_len should equal 2
    The variable arr_1_0 should equal nested
    The variable arr_1_1 should equal value
    The variable arr_2 should be undefined
    The variable arr_3 should equal ''
    The variable arr should equal "$before_sig"
    The variable SX_SYS_REV should equal "$before_rev"
    The variable SX_CFG_ARR_REF should equal '@'
    The variable SX_CFG_ARR_HOLE should equal hole
  End

  It 'pop_raw の要素不足では分配先・元配列・カウンタを変更しない'
    sx_arr_gen arr a
    x=original
    before_sig=$arr
    before_rev=$SX_SYS_REV
    When call __sx_arr_pop_raw x:y: arr
    The status should equal 1
    The variable x should equal original
    The variable y should be undefined
    The variable arr_len should equal 1
    The variable arr_0 should equal a
    The variable arr should equal "$before_sig"
    The variable SX_SYS_REV should equal "$before_rev"
  End

  It 'pop_raw の分配先配列にはリビジョンを発行し元配列の署名は保持する'
    sx_arr_gen arr a b c
    before_sig=$arr
    before_rev=$SX_SYS_REV
    When call __sx_arr_pop_raw 2out: arr
    The status should be success
    The variable out_len should equal 2
    The variable out_0 should equal c
    The variable out_1 should equal b
    The variable out should equal "${SX_CFG_SIG_ARR}:${before_rev}"
    The variable arr_len should equal 1
    The variable arr should equal "$before_sig"
    The variable SX_SYS_REV should equal "$((before_rev + 1))"
  End

  Context '通常の内部関数と公開 API の更新方針'
    Parameters
      0 0
      0 1
      1 0
      1 1
    End

    It 'push は設定と検証省略の有無に従い更新を一度だけ行う'
      sx_cfg_set "ARR_UPDATE=$1" "SKIP_CHK=$2"
      sx_arr_gen arr a
      before_sig=$arr
      before_rev=$SX_SYS_REV
      When call sx_arr_push arr b
      The status should be success
      The variable arr_1 should equal b
      The variable SX_SYS_REV should equal "$((before_rev + $1))"
      The variable SX_CFG_ARR_UPDATE should equal "$1"
      if [ "$1" = 0 ]; then
        The variable arr should equal "$before_sig"
      else
        The variable arr should equal "${SX_CFG_SIG_ARR}:${before_rev}"
      fi
    End

    It 'splice は設定と検証省略の有無に従い更新を一度だけ行う'
      sx_cfg_set "ARR_UPDATE=$1" "SKIP_CHK=$2"
      sx_arr_gen arr a b
      before_sig=$arr
      before_rev=$SX_SYS_REV
      When call sx_arr_splice arr 1 1 x
      The status should be success
      The variable arr_1 should equal x
      The variable SX_SYS_REV should equal "$((before_rev + $1))"
      The variable SX_CFG_ARR_UPDATE should equal "$1"
      if [ "$1" = 0 ]; then
        The variable arr should equal "$before_sig"
      else
        The variable arr should equal "${SX_CFG_SIG_ARR}:${before_rev}"
      fi
    End

    It 'pop は成功したときだけ設定に従い更新を一度だけ行う'
      sx_cfg_set "ARR_UPDATE=$1" "SKIP_CHK=$2"
      sx_arr_gen arr a b
      before_sig=$arr
      before_rev=$SX_SYS_REV
      When call sx_arr_pop x: arr
      The status should be success
      The variable x should equal b
      The variable arr_len should equal 1
      The variable SX_SYS_REV should equal "$((before_rev + $1))"
      The variable SX_CFG_ARR_UPDATE should equal "$1"
      if [ "$1" = 0 ]; then
        The variable arr should equal "$before_sig"
      else
        The variable arr should equal "${SX_CFG_SIG_ARR}:${before_rev}"
      fi
    End

    It 'gen は設定と検証省略の有無にかかわらず一度だけ更新し設定値を保持する'
      sx_cfg_set "ARR_UPDATE=$1" "SKIP_CHK=$2"
      before_rev=$SX_SYS_REV
      When call sx_arr_gen arr a b
      The status should be success
      The variable arr_len should equal 2
      The variable arr_0 should equal a
      The variable arr_1 should equal b
      The variable arr should equal "${SX_CFG_SIG_ARR}:${before_rev}"
      The variable SX_SYS_REV should equal "$((before_rev + 1))"
      The variable SX_CFG_ARR_UPDATE should equal "$1"
    End
  End

  Context '配列へ分配する pop'
    Parameters
      0
      1
    End

    It '分配先の生成が元配列の更新方針を変更しない'
      sx_cfg_set "ARR_UPDATE=$1"
      sx_arr_gen arr a b c
      before_sig=$arr
      before_rev=$SX_SYS_REV
      When call sx_arr_pop 2out: arr
      The status should be success
      The variable out_0 should equal c
      The variable out_1 should equal b
      The variable arr_len should equal 1
      The variable SX_SYS_REV should equal "$((before_rev + 1 + $1))"
      The variable SX_CFG_ARR_UPDATE should equal "$1"
      if [ "$1" = 0 ]; then
        The variable arr should equal "$before_sig"
      else
        The variable arr should equal "${SX_CFG_SIG_ARR}:$((before_rev + 1))"
      fi
    End
  End

  Context 'bind の途中では更新しない'
    Parameters
      sx_var_bind 0 '@arr'
      sx_var_bind 1 '@arr'
      sx_var_bind 0 '1@arr:tail'
      sx_var_bind 1 '1@arr:tail'
      sx_var_ubind 0 '@arr'
      sx_var_ubind 1 '@arr'
      sx_var_ubind 0 '1@arr:tail'
      sx_var_ubind 1 '1@arr:tail'
    End

    It '配列への追加は署名と設定値を保持する'
      sx_cfg_set "ARR_UPDATE=$2"
      sx_var_bind_init "$3"
      before_sig=$arr
      before_rev=$SX_SYS_REV
      When call "$1" rest "$3" x y
      The status should be success
      The variable arr_0 should equal x
      The variable arr should equal "$before_sig"
      The variable SX_SYS_REV should equal "$before_rev"
      The variable SX_CFG_ARR_UPDATE should equal "$2"
    End
  End
End
