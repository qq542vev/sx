Describe 'sx_arg_resize -efu 環境検証'
  sxtest_load ./build/modules/sx_arg_resize.sh

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
  It '巨大な形状と左パディングを処理する'
    When run efu_run sx_arg_resize 'a:b:' 1000000000000000000000000000000:2 p 2 ::: x
    The status should be success
  End

  It '巨大な軸と -1 の推論を処理する'
    When run efu_run sx_arg_resize 'a:b:' 1000000000000000000000000000000:-1 ::: x y
    The status should be success
  End

  It '0の軸より内側の巨大な形状を省略する'
    When run efu_run sx_arg_resize res 2:0:1000000000000000000000000000000 ::: x
    The status should be success
  End
End
