Describe 'sx_str_splice -efu 環境検証'
  Include ./sx.sh

  It '正常動作'
    When run efu_run sx_str_splice res "a*b?c[d" 2 1 "X"
    The status should be success
  End
End
