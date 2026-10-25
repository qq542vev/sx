# shellcheck disable=SC2016 # CMD内の変数は準備用シェルで展開する。
# shellcheck shell=sh
# ShellSpec 経由で呼び出す検証ヘルパー。
# shellcheck disable=SC2329

Describe '配列のリビジョン更新と raw 処理 -efu 環境検証'
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
      *) return 64;;
    esac
  }

  Include ./spec/support/run.sh

  updated_checked() {
    # shellcheck disable=SC3040
    set -efu -o posix
    case "$1" in
      *arr_push) "$1" arr x;;
      *arr_splice) "$1" arr 1 1 x;;
      *arr_pop) "$1" out: arr;;
      *) return 64;;
    esac
    # 配列署名は準備用シェルからの参照渡しで設定される。
    # shellcheck disable=SC2154
    case "$arr" in "${SX_CFG_SIG_ARR}:$before_rev") ;; *) return 1;; esac
    case "$SX_SYS_REV" in "$((before_rev + 1))") ;; *) return 1;; esac
    check_no_leak
  }

  Context '通常版は更新設定を参照しない'
    Parameters
      sx_arr_push 0
      sx_arr_push unset
      sx_arr_push invalid
      sx_arr_splice 0
      sx_arr_splice unset
      sx_arr_splice invalid
      sx_arr_pop 0
      sx_arr_pop unset
      sx_arr_pop invalid
      __sx_arr_push 0
      __sx_arr_push unset
      __sx_arr_push invalid
      __sx_arr_splice 0
      __sx_arr_splice unset
      __sx_arr_splice invalid
      __sx_arr_pop 0
      __sx_arr_pop unset
      __sx_arr_pop invalid
    End

    It '一度だけ更新し、内部変数を残さず成功する'
      load_subject "$1"
      sxtest_run arr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" arr a b c
      before_rev=$SX_SYS_REV
      case "$2" in
        unset) unset SX_CFG_ARR_UPDATE;;
        invalid) SX_CFG_ARR_UPDATE=invalid;;
        *) sxtest_run SX_CFG_ARR_UPDATE -- 'sx_cfg_set "$@"' "ARR_UPDATE=$2";;
      esac
      When run updated_checked "$1"
      The status should be success
    End
  End

  raw_checked() {
    # shellcheck disable=SC3040
    set -efu -o posix
    SX_SYS_REV=${SX_SYS_REV-0}
    sxtest_run arr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" arr a b c
    # 配列署名は sx_arr_gen による参照渡しで設定される。
    # shellcheck disable=SC2154
    before_sig=$arr
    before_rev=$SX_SYS_REV
    case "$1" in
      push) __sx_arr_push_raw arr x;;
      splice) __sx_arr_splice_raw arr 1 1 x;;
      pop) __sx_arr_pop_raw out: arr;;
    esac
    case "$arr" in "$before_sig") ;; *) return 1;; esac
    case "$SX_SYS_REV" in "$before_rev") ;; *) return 1;; esac
    check_no_leak
  }

  Context '更新設定に依存しない raw 処理'
    Parameters
      push 0
      push 1
      splice 0
      splice 1
      pop 0
      pop 1
    End

    It '元配列の署名とカウンタを保持し作業変数を残さない'
      case "$1" in
        push)
          load_subject __sx_arr_push_raw
          ;;
        splice)
          load_subject __sx_arr_splice_raw
          ;;
        pop)
          load_subject __sx_arr_pop_raw
          ;;
        *) return 64;;
      esac
      sxtest_run SX_CFG_ARR_UPDATE -- 'sx_cfg_set "$@"' "ARR_UPDATE=$2"
      When run raw_checked "$1"
      The status should be success
    End
  End

  It 'pop_raw の要素不足が -e 下でも1として返る'
    load_subject __sx_arr_pop_raw
    sxtest_run arr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" arr a
    When run efu_run __sx_arr_pop_raw x:y: arr
    The status should equal 1
  End
End
