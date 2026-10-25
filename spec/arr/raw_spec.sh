#!/bin/sh
# shellcheck disable=SC2016 # CMD内の変数は準備用シェルで展開する。
# shellcheck shell=sh
# ShellSpec の Parameters と動的な配列要素を検証する。
# shellcheck disable=SC2154

Describe '配列操作とリビジョン更新の分離'
  # Exampleごとに対象だけを読み込む。
  load_subject() {
    case "$1" in
      __sx_arr_push_raw)
        sxtest_load ./build/modules/__sx_arr_push_raw.sh
        ;;
      __sx_arr_splice_raw)
        sxtest_load ./build/modules/__sx_arr_splice_raw.sh
        ;;
      __sx_arr_pop_raw)
        sxtest_load ./build/modules/__sx_arr_pop_raw.sh
        ;;
      sx_arr_push)
        sxtest_load ./build/modules/sx_arr_push.sh
        ;;
      sx_arr_splice)
        sxtest_load ./build/modules/sx_arr_splice.sh
        ;;
      sx_arr_pop)
        sxtest_load ./build/modules/sx_arr_pop.sh
        ;;
      __sx_arr_push)
        sxtest_load ./build/modules/__sx_arr_push.sh
        ;;
      __sx_arr_splice)
        sxtest_load ./build/modules/__sx_arr_splice.sh
        ;;
      __sx_arr_pop)
        sxtest_load ./build/modules/__sx_arr_pop.sh
        ;;
      sx_arr_gen)
        sxtest_load ./build/modules/sx_arr_gen.sh
        ;;
      sx_var_bind)
        sxtest_load ./build/modules/sx_var_bind.sh
        ;;
      sx_var_ubind)
        sxtest_load ./build/modules/sx_var_ubind.sh
        ;;
      *) return 64;;
    esac
  }

  Include ./spec/support/run.sh

  normal_mutate() {
    case "$1" in
      *arr_push) "$1" arr x;;
      *arr_splice) "$1" arr 1 1 x;;
      *arr_pop) "$1" out: arr;;
      *) return 64;;
    esac
  }

  Context '通常版は ARR_UPDATE を要求しない'
    Parameters
      sx_arr_push 0
      sx_arr_push 1
      sx_arr_push unset
      sx_arr_push invalid
      sx_arr_splice 0
      sx_arr_splice 1
      sx_arr_splice unset
      sx_arr_splice invalid
      sx_arr_pop 0
      sx_arr_pop 1
      sx_arr_pop unset
      sx_arr_pop invalid
      __sx_arr_push 0
      __sx_arr_push 1
      __sx_arr_push unset
      __sx_arr_push invalid
      __sx_arr_splice 0
      __sx_arr_splice 1
      __sx_arr_splice unset
      __sx_arr_splice invalid
      __sx_arr_pop 0
      __sx_arr_pop 1
      __sx_arr_pop unset
      __sx_arr_pop invalid
    End

    It '設定値に依存せず成功時にリビジョンを一度だけ更新する'
      load_subject "$1"
      sxtest_run arr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" arr a b c
      before_rev=$SX_SYS_REV
      case "$2" in
        unset) unset SX_CFG_ARR_UPDATE;;
        invalid) SX_CFG_ARR_UPDATE=invalid;;
        *) sxtest_run SX_CFG_ARR_UPDATE -- 'sx_cfg_set "$@"' "ARR_UPDATE=$2";;
      esac
      When call normal_mutate "$1"
      The status should be success
      The variable arr should equal "${SX_CFG_SIG_ARR}:$before_rev"
      The variable SX_SYS_REV should equal "$((before_rev + 1))"
      case "$1" in
        *arr_push)
          The variable arr_len should equal 4
          The variable arr_3 should equal x
          ;;
        *arr_splice)
          The variable arr_len should equal 3
          The variable arr_1 should equal x
          ;;
        *arr_pop)
          The variable arr_len should equal 2
          The variable out should equal c
          The variable arr_2 should be undefined
          ;;
      esac
      case "$2" in
        unset)
          The variable SX_CFG_ARR_UPDATE should be undefined
          ;;
        *)
          The variable SX_CFG_ARR_UPDATE should equal "$2"
          ;;
      esac
    End
  End

  Context '通常版は変更量ゼロでも更新する'
    Parameters
      sx_arr_push
      __sx_arr_push
      sx_arr_splice
      __sx_arr_splice
    End

    It '元の要素と長さを保持し、リビジョンを一度だけ更新する'
      load_subject "$1"
      sxtest_run arr SX_SYS_REV SX_CFG_ARR_UPDATE -- '
        SX_SYS_REV=$1
        sx_cfg_set ARR_UPDATE=0
        sx_arr_gen arr a b c
      ' "${SX_SYS_REV-0}"
      before_rev=$SX_SYS_REV
      case "$1" in
        *arr_push) set -- "$1" arr;;
        *arr_splice) set -- "$1" arr 1 0;;
      esac
      When call "${@}"
      The status should be success
      The variable arr_len should equal 3
      The variable arr_0 should equal a
      The variable arr_1 should equal b
      The variable arr_2 should equal c
      The variable arr should equal "${SX_CFG_SIG_ARR}:$before_rev"
      The variable SX_SYS_REV should equal "$((before_rev + 1))"
    End
  End

  Context '通常版 pop の要素不足'
    Parameters
      sx_arr_pop 0
      sx_arr_pop 1
      __sx_arr_pop 0
      __sx_arr_pop 1
    End

    It '1を返し、元配列・分配先・カウンタを変更しない'
      load_subject "$1"
      sxtest_run arr SX_SYS_REV SX_CFG_ARR_UPDATE SX_CFG_SKIP_CHK -- '
        SX_SYS_REV=$1
        sx_cfg_set ARR_UPDATE=0 "SKIP_CHK=$2"
        sx_arr_gen arr a
      ' "${SX_SYS_REV-0}" "$2"
      before_sig=$arr
      before_rev=$SX_SYS_REV
      x=original
      When call "$1" x:y: arr
      The status should equal 1
      The variable x should equal original
      The variable y should be undefined
      The variable arr_len should equal 1
      The variable arr_0 should equal a
      The variable arr should equal "$before_sig"
      The variable SX_SYS_REV should equal "$before_rev"
    End
  End

  Context 'raw の元配列は更新しない'
    Parameters
      0
      1
    End

    It 'push_raw は設定にかかわらず末尾へ追加し署名とカウンタを保持する'
      load_subject __sx_arr_push_raw
      SX_SYS_REV=${SX_SYS_REV-0}
      sxtest_run SX_CFG_ARR_UPDATE -- 'sx_cfg_set "$@"' "ARR_UPDATE=$1"
      sxtest_run arr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" arr a
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
      load_subject __sx_arr_splice_raw
      SX_SYS_REV=${SX_SYS_REV-0}
      sxtest_run SX_CFG_ARR_UPDATE -- 'sx_cfg_set "$@"' "ARR_UPDATE=$1"
      sxtest_run arr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" arr a b c
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
      load_subject __sx_arr_pop_raw
      SX_SYS_REV=${SX_SYS_REV-0}
      sxtest_run SX_CFG_ARR_UPDATE -- 'sx_cfg_set "$@"' "ARR_UPDATE=$1"
      sxtest_run arr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" arr a b c
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
    load_subject __sx_arr_push_raw
    SX_SYS_REV=${SX_SYS_REV-0}
    setup_command='
      SX_SYS_REV=$1
      sx_arr_gen src nested value
      sx_arr_gen arr head
      sx_cfg_set ARR_REF=@ ARR_HOLE=hole
    '
    sxtest_run src arr SX_CFG_ARR_REF SX_CFG_ARR_HOLE SX_SYS_REV -- "$setup_command" "${SX_SYS_REV-0}"
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
    load_subject __sx_arr_pop_raw
    SX_SYS_REV=${SX_SYS_REV-0}
    sxtest_run arr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" arr a
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
    load_subject __sx_arr_pop_raw
    SX_SYS_REV=${SX_SYS_REV-0}
    sxtest_run arr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" arr a b c
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

    It 'push は設定と検証省略の有無にかかわらず更新を一度だけ行う'
      load_subject sx_arr_push
      SX_SYS_REV=${SX_SYS_REV-0}
      sxtest_run SX_CFG_ARR_UPDATE SX_CFG_SKIP_CHK -- 'sx_cfg_set "$@"' "ARR_UPDATE=$1" "SKIP_CHK=$2"
      sxtest_run arr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" arr a
      before_sig=$arr
      before_rev=$SX_SYS_REV
      When call sx_arr_push arr b
      The status should be success
      The variable arr_1 should equal b
      The variable SX_SYS_REV should equal "$((before_rev + 1))"
      The variable SX_CFG_ARR_UPDATE should equal "$1"
      The variable arr should equal "${SX_CFG_SIG_ARR}:${before_rev}"
    End

    It 'splice は設定と検証省略の有無にかかわらず更新を一度だけ行う'
      load_subject sx_arr_splice
      SX_SYS_REV=${SX_SYS_REV-0}
      sxtest_run SX_CFG_ARR_UPDATE SX_CFG_SKIP_CHK -- 'sx_cfg_set "$@"' "ARR_UPDATE=$1" "SKIP_CHK=$2"
      sxtest_run arr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" arr a b
      before_sig=$arr
      before_rev=$SX_SYS_REV
      When call sx_arr_splice arr 1 1 x
      The status should be success
      The variable arr_1 should equal x
      The variable SX_SYS_REV should equal "$((before_rev + 1))"
      The variable SX_CFG_ARR_UPDATE should equal "$1"
      The variable arr should equal "${SX_CFG_SIG_ARR}:${before_rev}"
    End

    It 'pop は設定と検証省略の有無にかかわらず成功時に更新を一度だけ行う'
      load_subject sx_arr_pop
      SX_SYS_REV=${SX_SYS_REV-0}
      sxtest_run SX_CFG_ARR_UPDATE SX_CFG_SKIP_CHK -- 'sx_cfg_set "$@"' "ARR_UPDATE=$1" "SKIP_CHK=$2"
      sxtest_run arr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" arr a b
      before_sig=$arr
      before_rev=$SX_SYS_REV
      When call sx_arr_pop x: arr
      The status should be success
      The variable x should equal b
      The variable arr_len should equal 1
      The variable SX_SYS_REV should equal "$((before_rev + 1))"
      The variable SX_CFG_ARR_UPDATE should equal "$1"
      The variable arr should equal "${SX_CFG_SIG_ARR}:${before_rev}"
    End

    It 'gen は設定と検証省略の有無にかかわらず一度だけ更新し設定値を保持する'
      load_subject sx_arr_gen
      SX_SYS_REV=${SX_SYS_REV-0}
      sxtest_run SX_CFG_ARR_UPDATE SX_CFG_SKIP_CHK -- 'sx_cfg_set "$@"' "ARR_UPDATE=$1" "SKIP_CHK=$2"
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
      load_subject sx_arr_pop
      SX_SYS_REV=${SX_SYS_REV-0}
      sxtest_run SX_CFG_ARR_UPDATE -- 'sx_cfg_set "$@"' "ARR_UPDATE=$1"
      sxtest_run arr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" arr a b c
      before_sig=$arr
      before_rev=$SX_SYS_REV
      When call sx_arr_pop 2out: arr
      The status should be success
      The variable out_0 should equal c
      The variable out_1 should equal b
      The variable arr_len should equal 1
      The variable SX_SYS_REV should equal "$((before_rev + 2))"
      The variable SX_CFG_ARR_UPDATE should equal "$1"
      The variable out should equal "${SX_CFG_SIG_ARR}:${before_rev}"
      The variable arr should equal "${SX_CFG_SIG_ARR}:$((before_rev + 1))"
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
      load_subject "$1"
      SX_SYS_REV=${SX_SYS_REV-0}
      sxtest_run SX_CFG_ARR_UPDATE -- 'sx_cfg_set "$@"' "ARR_UPDATE=$2"
      sxtest_run arr tail SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_var_bind_init "$@"' "${SX_SYS_REV-0}" "$3"
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
