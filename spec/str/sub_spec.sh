Describe 'sx_str_sub'
  Include ./sx.sh
  It 'パターンを文字列で置換すること'
    When call sx_str_sub result "hello world" "world" "earth"
    The variable result should equal "hello earth"
  End

  It 'パターンが見つからない場合は何もしないこと'
    When call sx_str_sub result "hello world" "foo" "bar"
    The variable result should equal "hello world"
  End

  It '空文字列で置換できること'
    When call sx_str_sub result "hello world" "hello " ""
    The variable result should equal "world"
  End

  Context '方向と制限を指定した場合'
    It 'デフォルトで前方から置換すること'
      When call sx_str_sub res "a.b.c.d" "." "_"
      The variable res should equal "a_b_c_d"
    End

    It '制限付きで前方から置換すること'
      When call sx_str_sub res "a.b.c.d" "." "_" 1 f
      The variable res should equal "a_b.c.d"
    End

    It '後方から置換すること'
      When call sx_str_sub res "a.b.c.d" "." "_" 2147483647 b
      The variable res should equal "a_b_c_d"
    End

    It '制限付きで後方から置換すること'
      When call sx_str_sub res "a.b.c.d" "." "_" 1 b
      The variable res should equal "a.b.c_d"
    End

    It '制限2で後方から置換すること'
      When call sx_str_sub res "a.b.c.d" "." "_" 2 b
      The variable res should equal "a.b_c_d"
    End
  End
End
