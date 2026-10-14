Describe 'sx_arg_join -efu 環境検証'
  Include ./sx.sh

  It '引数個数が安全範囲外でも-efu下で成功すること'
    __sx_num_is_nat0_safe() {
      case "${1-}" in 5) return 1;; esac
      return 0
    }
    When run efu_run sx_arg_join result : 'a b' '' "c'd"
    The status should be success
  End

  It '正常動作'

    When run efu_run sx_arg_join result ":" "a" "b" "c"
    The status should be success
  End
End
