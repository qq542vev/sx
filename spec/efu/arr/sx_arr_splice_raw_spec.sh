# shellcheck shell=sh
# shellcheck disable=SC2016,SC2154,SC2329 # 準備用コード、参照渡し、ShellSpec のコールバック。

Describe 'sx_arr_splice_raw -efu 環境検証'
  Include ./spec/support/run.sh

  setup_splice_raw_efu() {
    unset SX_CFG_SIG_ARR SX_CFG_SKIP_CHK SX_CFG_NUM_RANGE SX_CFG_SEP \
      SX_CFG_ARR_HOLE SX_CFG_ARR_REF
    sxtest_load ./build/modules/sx_arr_splice_raw.sh
    sxtest_run arr SX_SYS_REV -- 'sx_cfg_set; sx_arr_gen arr a b c'
    before_sig=$arr
    before_rev=$SX_SYS_REV
  }
  BeforeEach setup_splice_raw_efu

  checked_splice_raw() {
    # shellcheck disable=SC3040
    set -efu -o posix
    sx_arr_splice_raw arr "$@"
    case "$arr:$SX_SYS_REV" in "$before_sig:$before_rev") ;; *) return 1;; esac
    check_no_leak
  }

  Context '検査省略の有無'
    Parameters
      0
      1
    End

    It 'リビジョンを保持し、内部変数を残さず成功する'
      sxtest_run SX_CFG_SKIP_CHK -- 'sx_cfg_set "$@"' "SKIP_CHK=$1"
      When run checked_splice_raw 1 1 x
      The status should be success
    End
  End

  Context '範囲外の操作と検査省略の有無'
    Parameters
      0 '-1000' 0 X
      1 '-1000' 0 X
      0 10000 0 X
      1 10000 0 X
      0 '-5' 1
      1 '-5' 1
      0 '-5' '' X
      1 '-5' '' X
    End

    It '範囲外の挿入・削除でも内部変数を残さず成功する'
      sxtest_run SX_CFG_SKIP_CHK -- 'sx_cfg_set "$@"' "SKIP_CHK=$1"
      shift
      When run checked_splice_raw "$@"
      The status should be success
      The stdout should equal ''
      The stderr should equal ''
    End
  End

  It '引数不正は64として返る'
    When run efu_run sx_arr_splice_raw
    The status should equal 64
  End
End
