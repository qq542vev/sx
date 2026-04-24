Describe 'sx_num_is_uint'
  Include ./sx.sh
  It '有効な正の整数（符号なし整数）に対して成功を返すこと'
    When call sx_num_is_uint "123" "0" "456"
    The status should be success
  End

  It '先頭に0がある数値に対して失敗を返すこと'
    When call sx_num_is_uint "01"
    The status should be failure
  End

  It '数字以外の文字列に対して失敗を返すこと'
    When call sx_num_is_uint "123a"
    The status should be failure
  End
End
