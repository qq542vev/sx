Describe 'sx_str_pad -efu 環境検証'
  Include ./sx.sh

  It '正常動作'

    When run efu_run sx_str_pad res "A" 3 ""
    The status should be success
  End
End
