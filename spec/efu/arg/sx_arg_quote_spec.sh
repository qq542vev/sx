Describe 'sx_arg_quote -efu 環境検証'
  Include ./sx.sh

  It '正常動作'

    When run efu_run sx_arg_quote encoded_args "$@"
    The status should be success
  End
End
