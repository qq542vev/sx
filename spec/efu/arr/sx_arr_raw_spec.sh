# shellcheck shell=sh
# ShellSpec 経由で呼び出す検証ヘルパー。
# shellcheck disable=SC2329

Describe '配列 raw 処理 -efu 環境検証'
  Include ./spec/support/library.sh spec/efu/arr/sx_arr_raw_spec.sh SX_SYS_REV __sx_arr_pop_raw __sx_arr_push_raw __sx_arr_splice_raw sx_arr_gen sx_cfg_set

  raw_checked() {
    # shellcheck disable=SC3040
    set -efu -o posix
    sx_arr_gen arr a b c
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
      sx_cfg_set "ARR_UPDATE=$2"
      When run raw_checked "$1"
      The status should be success
    End
  End

  It 'pop_raw の要素不足が -e 下でも1として返る'
    sx_arr_gen arr a
    When run efu_run __sx_arr_pop_raw x:y: arr
    The status should equal 1
  End
End
