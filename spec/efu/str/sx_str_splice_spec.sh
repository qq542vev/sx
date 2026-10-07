Describe 'sx_str_splice -efu 環境検証'
  Include ./sx.sh

  It '正常動作'
    When run efu_run sx_str_splice res "a*b?c[d" 2 1 "X"
    The status should be success
  End
  It '多倍長の開始位置と削除数を外部コマンドなしで処理すること'
    When run efu_run sx_str_splice res abcd -1000000000000000000000000000000 999999999999999999999999999997
    The status should be success
  End

  Context '空の数値引数'
    Parameters
      '' '2'
      '2' ''
      '' ''
    End

    It '既定値として正常に処理すること'
      When run efu_run sx_str_splice res abcd "$1" "$2" X
      The status should be success
      The stderr should equal ''
    End
  End
End
