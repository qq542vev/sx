Describe 'sx_glob_esc_eq -efu 環境検証'
  sxtest_load ./build/modules/sx_glob_esc_eq.sh

  Parameters
    0
    1
  End

  It '等価クラス化とエスケープを行い、内部変数を残さない'
    SX_CFG_SKIP_CHK=$1
    verify_eq() {
      sx_glob_esc_eq result 'a*!=' 'a!=' '!'
      case "$result" in '[[=a=]][*][[=!=]][[===]]') ;; *) return 1;; esac
      case 'a*!=' in $result) ;; *) return 1;; esac
      check_no_leak
      sx_glob_esc_eq result 'a!^]' '' '!^]'
      case "$result" in 'a[[.!.]][[.^.]][]]') ;; *) return 1;; esac
      check_no_leak
      sx_glob_esc_eq result
      case "$result" in '') ;; *) return 1;; esac
      check_no_leak
    }
    When run efu_run verify_eq
    The status should be success
    The stdout should equal ''
    The stderr should equal ''
  End
End
