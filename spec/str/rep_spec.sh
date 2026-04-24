Describe 'sx_str_rep'
  Include ./sx.sh
  It '指定された回数だけ文字列を繰り返すこと'
    When call sx_str_rep res "a" 3
    The variable res should equal "aaa"
  End

  It '0回繰り返した場合に空文字列を返すこと'
    When call sx_str_rep res "abc" 0
    The variable res should equal ""
  End

  It '1回繰り返した場合に同じ文字列を返すこと'
    When call sx_str_rep res "abc" 1
    The variable res should equal "abc"
  End

  It '2のべき乗ではない回数を処理できること'
    When call sx_str_rep res "x" 7
    The variable res should equal "xxxxxxx"
  End

  It '大きな回数を処理できること'
    When call sx_str_rep res "ab" 13
    The variable res should equal "ababababababababababababab"
  End

  It '空文字列を処理できること'
    When call sx_str_rep res "" 10
    The variable res should equal ""
  End

  It '回数が省略された場合にデフォルトの1回になること'
    When call sx_str_rep res "z"
    The variable res should equal "z"
  End

  It '文字列が省略された場合にデフォルトの空文字列になること'
    When call sx_str_rep res
    The variable res should equal ""
  End

  It '負の回数に対してEX_USAGE (64)を返すこと'
    When call sx_str_rep res "a" -1
    The status should equal 64
  End

  It '整数ではない回数に対してEX_USAGE (64)を返すこと'
    When call sx_str_rep res "a" "abc"
    The status should equal 64
  End

  It '読み取り専用の変数に対してEX_NOPERM (77)を返すこと'
    readonly ro_res_rep="fixed"
    When call sx_str_rep ro_res_rep "a" 3
    The status should equal 77
  End
End
