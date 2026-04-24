Describe 'sx_str_match'
  Include ./sx.sh
  It 'returns success if the first argument matches any subsequent pattern (glob)'
    When call sx_str_match "file.txt" "*.txt" "*.md"
    The status should be success
  End

  It 'returns failure if no pattern matches'
    When call sx_str_match "file.txt" "*.md"
    The status should be failure
  End

  It 'handles character classes in glob'
    When call sx_str_match "file1" "file[0-9]"
    The status should be success
  End
End
