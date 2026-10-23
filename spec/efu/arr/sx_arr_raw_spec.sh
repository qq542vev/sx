# shellcheck disable=SC2016 # CMD内の変数は準備用シェルで展開する。
# shellcheck shell=sh
# ShellSpec 経由で呼び出す検証ヘルパー。
# shellcheck disable=SC2329

Describe '配列 raw 処理 -efu 環境検証'
  # Exampleごとに対象だけを読み込む。IncludeはExampleの外で宣言する。
  load_subject() {
    case "$1" in
      __sx_arr_push_raw)
        Include ./spec/support/library.sh __sx_arr_push_raw
        ;;
      __sx_arr_splice_raw)
        Include ./spec/support/library.sh __sx_arr_splice_raw
        ;;
      __sx_arr_pop_raw)
        Include ./spec/support/library.sh __sx_arr_pop_raw
        ;;
      *) return 64;;
    esac
  }

  Include ./spec/support/run.sh

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
