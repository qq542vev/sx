Describe 'sx_arg_resize -efu 環境検証'
  Include ./sx.sh

  It '正常動作'

    When run efu_run sx_arg_resize res 2:3 0 ::: a b c d
    The status should be success
  End
End
