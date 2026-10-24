Describe 'sx_str_match -efu 環境検証'
  sxtest_load ./build/modules/sx_str_match.sh

  It '正常動作'

    When run efu_run sx_str_match "file.txt" "*.txt" "*.md"
    The status should be success
  End
End
