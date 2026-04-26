Describe 'sx_str_sub'
  Include ./sx.sh
  It 'パターンを文字列で置換すること'
    When call sx_str_sub result "hello world" "world" "earth"
    The status should be success
    The variable result should equal "hello earth"
  End

  It 'パターンが見つからない場合は何もしないこと'
    When call sx_str_sub result "hello world" "foo" "bar"
    The status should be success
    The variable result should equal "hello world"
  End

  It '空文字列で置換（削除）できること'
    When call sx_str_sub result "hello world" "hello " ""
    The status should be success
    The variable result should equal "world"
  End

  It '特殊文字を含む置換ができること'
    When call sx_str_sub result "a'b\"c\\d" "'" "_"
    The status should be success
    The variable result should equal "a_b\"c\\d"
  End

  Context '方向と制限を指定した場合'
    It 'デフォルトで前方からすべて置換すること'
      When call sx_str_sub res "a.b.c.d" "." "_"
      The variable res should equal "a_b_c_d"
    End

    It '制限1で前方から置換すること'
      When call sx_str_sub res "a.b.c.d" "." "_" 1 f
      The variable res should equal "a_b.c.d"
    End

    It '制限2で前方から置換すること'
      When call sx_str_sub res "a.b.c.d" "." "_" 2 f
      The variable res should equal "a_b_c.d"
    End

    It '制限1で後方から置換すること'
      When call sx_str_sub res "a.b.c.d" "." "_" 1 b
      # 期待値: a.b.c_d (後方から1つ)
      The variable res should equal "a.b.c_d"
    End

    It '制限2で後方から置換すること'
      When call sx_str_sub res "a.b.c.d" "." "_" 2 b
      # 期待値: a.b_c_d (後方から2つ)
      The variable res should equal "a.b_c_d"
    End
  End

  It '無効な引数（方向不正）に対して EX_USAGE を返すこと'
    When call sx_str_sub result "a.b" "." "_" 1 "x"
    The status should equal 64
  End

  It '無効な引数（回数不正）に対して EX_USAGE を返すこと'
    When call sx_str_sub result "a.b" "." "_" "abc" f
    The status should equal 64
  End

  It '結果変数が読み取り専用の場合に EX_NOPERM を返すこと'
    readonly ro_res_sub="fixed"
    When call sx_str_sub ro_res_sub "a" "a" "b"
    The status should equal 77
  End
End
