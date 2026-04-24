Describe 'sx_str_rep'
  Include ./sx.sh
  It 'repeats a string a given number of times'
    When call sx_str_rep res "a" 3
    The variable res should equal "aaa"
  End

  It 'returns an empty string when repeated 0 times'
    When call sx_str_rep res "abc" 0
    The variable res should equal ""
  End

  It 'returns the same string when repeated 1 time'
    When call sx_str_rep res "abc" 1
    The variable res should equal "abc"
  End

  It 'handles non-power of 2 counts'
    When call sx_str_rep res "x" 7
    The variable res should equal "xxxxxxx"
  End

  It 'handles large counts'
    When call sx_str_rep res "ab" 13
    The variable res should equal "ababababababababababababab"
  End

  It 'handles empty strings'
    When call sx_str_rep res "" 10
    The variable res should equal ""
  End

  It 'defaults count to 1 if omitted'
    When call sx_str_rep res "z"
    The variable res should equal "z"
  End

  It 'defaults string to empty if omitted'
    When call sx_str_rep res
    The variable res should equal ""
  End

  It 'returns EX_USAGE (64) for negative counts'
    When call sx_str_rep res "a" -1
    The status should equal 64
  End

  It 'returns EX_USAGE (64) for non-integer counts'
    When call sx_str_rep res "a" "abc"
    The status should equal 64
  End

  It 'returns EX_NOPERM (77) for readonly result variables'
    readonly ro_res_rep="fixed"
    When call sx_str_rep ro_res_rep "a" 3
    The status should equal 77
  End
End
