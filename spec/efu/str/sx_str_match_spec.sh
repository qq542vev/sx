Describe 'sx_str_match -efu 環境検証'
  Include ./spec/support/library.sh sx_str_match

  It '正常動作'

    When run efu_run sx_str_match "file.txt" "*.txt" "*.md"
    The status should be success
  End
End
