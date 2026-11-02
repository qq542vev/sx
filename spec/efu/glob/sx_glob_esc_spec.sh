Describe 'sx_glob_esc -efu 環境検証'
  sxtest_load ./build/modules/sx_glob_esc.sh

  It '正常動作'
    When run efu_run sx_glob_esc result 'a*b'
    The status should be success
  End

  Parameters
    0
    1
  End

  It '検証省略の有無によらずバックスラッシュとglob文字を処理する'
    SX_CFG_SKIP_CHK=$1
    verify_backslash() {
      sx_glob_esc result '\*?\['
      case "$result" in '[\\][*][?][\\][[]') ;; *) return 1;; esac
      case '\*?\[' in $result) ;; *) return 1;; esac
      check_no_leak
    }
    When run efu_run verify_backslash
    The status should be success
    The stdout should equal ''
    The stderr should equal ''
  End
End
