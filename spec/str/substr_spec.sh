Describe 'sx_str_substr()'
  Include ./sx.sh

  BeforeRun 'PATH=""'

  It 'extracts substring from the middle'
    When call sx_str_substr res "abcdef" 2 3
    The variable res should equal "cde"
  End

  It 'extracts from the beginning'
    When call sx_str_substr res "abcdef" 0 3
    The variable res should equal "abc"
  End

  It 'extracts until the end when length is omitted'
    When call sx_str_substr res "abcdef" 2
    The variable res should equal "cdef"
  End

  It 'extracts until the end when length exceeds remaining'
    When call sx_str_substr res "abcdef" 4 10
    The variable res should equal "ef"
  End

  It 'returns empty string when offset exceeds string length'
    When call sx_str_substr res "abc" 5 2
    The variable res should equal ""
  End

  It 'returns empty string when length is 0'
    When call sx_str_substr res "abcdef" 2 0
    The variable res should equal ""
  End

  It 'handles strings with metacharacters (*, ?, [)'
    When call sx_str_substr res "a*b?c[d" 1 3
    The variable res should equal "*b?"
  End

  It 'handles empty source string'
    When call sx_str_substr res "" 0 5
    The variable res should equal ""
  End

  It 'returns error for non-numeric offset'
    When call sx_str_substr res "abc" "x"
    The status should equal 64
  End

  It 'returns error for non-numeric length'
    When call sx_str_substr res "abc" 1 "y"
    The status should equal 64
  End

  It 'returns error for readonly result variable'
    readonly MYRO_SUBSTR=1
    When call sx_str_substr MYRO_SUBSTR "abc" 0 1
    The status should equal 77
  End

  It 'extracts from the end with negative offset'
    When call sx_str_substr res "abcdef" -3
    The variable res should equal "def"
  End

  It 'extracts from the beginning if negative offset exceeds total length'
    When call sx_str_substr res "abcdef" -10
    The variable res should equal "abcdef"
  End

  It 'excludes trailing characters with negative length'
    When call sx_str_substr res "abcdef" 0 -2
    The variable res should equal "abcd"
  End

  It 'handles both negative offset and negative length'
    When call sx_str_substr res "abcdef" -4 -1
    The variable res should equal "cde"
  End

  It 'returns empty string if negative length excludes all characters'
    When call sx_str_substr res "abc" 1 -5
    The variable res should equal ""
  End
End
