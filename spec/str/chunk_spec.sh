Describe "sx_str_chunk"
  Include ./sx.sh

  It "chunks a string forward with positive length"
    When call sx_str_chunk res "abcde" 2
    The status should be success
    The variable res_len should equal 3
    The variable res_0 should equal "ab"
    The variable res_1 should equal "cd"
    The variable res_2 should equal "e"
  End

  It "chunks a string backward with negative length"
    When call sx_str_chunk res "abcde" -2
    The status should be success
    The variable res_len should equal 3
    The variable res_0 should equal "a"
    The variable res_1 should equal "bc"
    The variable res_2 should equal "de"
  End

  It "respects forward limit"
    When call sx_str_chunk res "abcde" 2 1
    The status should be success
    The variable res_len should equal 2
    The variable res_0 should equal "ab"
    The variable res_1 should equal "cde"
  End

  It "respects backward limit"
    When call sx_str_chunk res "abcde" -2 1
    The status should be success
    The variable res_len should equal 2
    The variable res_0 should equal "abc"
    The variable res_1 should equal "de"
  End

  It "handles length larger than string"
    When call sx_str_chunk res "abc" 10
    The status should be success
    The variable res_len should equal 1
    The variable res_0 should equal "abc"
  End

  It "handles negative length larger than string"
    When call sx_str_chunk res "abc" -10
    The status should be success
    The variable res_len should equal 1
    The variable res_0 should equal "abc"
  End

  It "handles empty string"
    When call sx_str_chunk res "" 2
    The status should be success
    The variable res_len should equal 0
  End

  It "handles special characters safely"
    When call sx_str_chunk res "a*b? c'd" 2
    The status should be success
    The variable res_len should equal 4
    The variable res_0 should equal "a*"
    The variable res_1 should equal "b?"
    The variable res_2 should equal " c"
    The variable res_3 should equal "'d"
  End

  It "returns EX_USAGE (64) for length 0"
    When call sx_str_chunk res "abc" 0
    The status should equal 64
  End

  It "returns EX_USAGE (64) for non-numeric length"
    When call sx_str_chunk res "abc" "invalid"
    The status should equal 64
  End

  It "returns EX_NOPERM (77) for readonly variable"
    readonly ro_var_chunk=fixed
    When call sx_str_chunk ro_var_chunk "abc" 2
    The status should equal 77
  End
End
