Describe 'sx_ex_map -efu 環境検証'
  Include ./sx.sh

  It '正常動作'

    When run efu_run sx_ex_map s OK
    The status should be success
  End
End
