Describe 'sx_glob_bracket -efu 環境検証'
  sxtest_load ./build/modules/sx_glob_bracket.sh

  It '正常動作'
    When run efu_run sx_glob_bracket result 'a'
    The status should be success
  End

  Context '括弧式の途中に特殊構文の開始文字が含まれる集合'
    Parameters:matrix
      ':[]' '=[]' '.[]' ']x[:' ']x[=' ']x[.'
      '[' ']'
    End

    It '-efu 下でも生成パターンが元の集合の各括弧に一致すること'
      verify_bracket_match() {
        sx_glob_bracket result "$1"
        check_no_leak
        case "$2" in
          $result) return 0;;
          *) return 1;;
        esac
      }

      When run efu_run verify_bracket_match "$1" "$2"
      The status should be success
      The stdout should equal ''
      The stderr should equal ''
    End
  End
End
