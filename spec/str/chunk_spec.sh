Describe "sx_str_chunk"
  Include ./sx.sh

  It "chunks a string forward with positive length"
    When call sx_str_chunk res "abcde" 2
    The status should be success
    The variable res should equal "'ab' 'cd' 'e'"
  End

  It "chunks a string backward with negative length"
    When call sx_str_chunk res "abcde" -2
    The status should be success
    The variable res should equal "'a' 'bc' 'de'"
  End

  It "respects forward limit"
    When call sx_str_chunk res "abcde" 2 1
    The status should be success
    The variable res should equal "'ab' 'cde'"
  End

  It "respects backward limit"
    When call sx_str_chunk res "abcde" -2 1
    The status should be success
    The variable res should equal "'abc' 'de'"
  End

  It "handles length larger than string"
    When call sx_str_chunk res "abc" 10
    The status should be success
    The variable res should equal "'abc'"
  End

  It "handles negative length larger than string"
    When call sx_str_chunk res "abc" -10
    The status should be success
    The variable res should equal "'abc'"
  End

  It "handles empty string"
    When call sx_str_chunk res "" 2
    The status should be success
    The variable res should equal ""
  End

  It "handles special characters safely"
    When call sx_str_chunk res "a*b? c'd" 2
    The status should be success
    The variable res should equal "'a*' 'b?' ' c' ''\''d'"
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
