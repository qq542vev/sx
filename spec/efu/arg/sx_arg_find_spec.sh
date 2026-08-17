Describe 'sx_arg_find -efu 環境検証'
  Include ./sx.sh

  It '正常動作'

    When run efu_run sx_arg_find res "b" ::: "a" "b" "c"
    The status should be success
  End
End
