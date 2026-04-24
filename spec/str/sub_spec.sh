Describe 'sx_str_sub'
  Include ./sx.sh
  It 'replaces a pattern with a string'
    When call sx_str_sub result "hello world" "world" "earth"
    The variable result should equal "hello earth"
  End

  It 'does nothing if the pattern is not found'
    When call sx_str_sub result "hello world" "foo" "bar"
    The variable result should equal "hello world"
  End

  It 'can replace with an empty string'
    When call sx_str_sub result "hello world" "hello " ""
    The variable result should equal "world"
  End

  Context 'with direction and limit'
    It 'replaces forward by default'
      When call sx_str_sub res "a.b.c.d" "." "_"
      The variable res should equal "a_b_c_d"
    End

    It 'replaces forward with limit'
      When call sx_str_sub res "a.b.c.d" "." "_" 1 f
      The variable res should equal "a_b.c.d"
    End

    It 'replaces backward'
      When call sx_str_sub res "a.b.c.d" "." "_" 2147483647 b
      The variable res should equal "a_b_c_d"
    End

    It 'replaces backward with limit'
      When call sx_str_sub res "a.b.c.d" "." "_" 1 b
      The variable res should equal "a.b.c_d"
    End

    It 'replaces backward with limit 2'
      When call sx_str_sub res "a.b.c.d" "." "_" 2 b
      The variable res should equal "a.b_c_d"
    End
  End
End
