Describe 'sx_arg_resize -efu 環境検証'
  Include ./sx.sh

  It '正常動作'

    When run efu_run sx_arg_resize res 2:3 0 ::: a b c d
    The status should be success
  End

  It '設定を省略した SEP 形式で正常動作する'
    When run efu_run sx_arg_resize res ::: a b
    The status should be success
  End

  It 'SEP なしでは第2引数を形状にする'
    When run efu_run sx_arg_resize res 2:2 a b c
    The status should be success
  End
End
