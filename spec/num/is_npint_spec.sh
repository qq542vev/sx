Describe 'sx_num_is_npint'
  Include ./sx.sh

  It '0以下の整数に対して成功を返すこと'
    When call sx_num_is_npint 0 -1 -100
    The status should be success
  End

  It '符号付きの0（+0, -0）に対して成功を返すこと'
    When call sx_num_is_npint +0 -0
    The status should be success
  End

  It '正の整数（符号なし）に対して失敗を返すこと'
    When call sx_num_is_npint 1
    The status should be failure
  End

  It '正の整数（符号あり）に対して失敗を返すこと'
    When call sx_num_is_npint +1
    The status should be failure
  End

  It '整数以外の文字列に対して失敗を返すこと'
    When call sx_num_is_npint "a" "" "1.5"
    The status should be failure
  End

  It '複数の引数で一つでも正の整数が含まれる場合に失敗を返すこと'
    When call sx_num_is_npint 0 -1 2 -3
    The status should be failure
  End
End
