Describe 'sx_arg_quote -efu 環境検証'
  Include ./spec/support/library.sh sx_arg_quote

  It '引数個数が安全範囲外でも-efu下で成功すること'
    __sx_num_is_nat0_safe() {
      case "${1-}" in 4) return 1;; esac
      return 0
    }
    When run efu_run sx_arg_quote 'head_arg:tail_args' 'a b' "c'd" ''
    The status should be success
  End

  It '正常動作'

    When run efu_run sx_arg_quote encoded_args "$@"
    The status should be success
  End
End
