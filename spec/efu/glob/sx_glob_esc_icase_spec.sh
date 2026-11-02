Describe 'sx_glob_esc_icase -efu 環境検証'
  sxtest_load ./build/modules/sx_glob_esc_icase.sh

  Parameters
    0
    1
  End

  It '検証省略の有無によらず英字と特殊文字を処理し、内部変数を残さない'
    SX_CFG_SKIP_CHK=$1
    verify_icase() {
      sx_glob_esc_icase result '01abCD6*?\['
      case "$result" in '01[Aa][Bb][Cc][Dd]6[*][?][\\][[]') ;; *) return 1;; esac
      case '01ABcd6*?\[' in $result) ;; *) return 1;; esac
      case '01ABcd6anything' in $result) return 1;; esac
      check_no_leak
      sx_glob_esc_icase result
      case "$result" in '') ;; *) return 1;; esac
      check_no_leak
    }
    When run efu_run verify_icase
    The status should be success
    The stdout should equal ''
    The stderr should equal ''
  End
End
