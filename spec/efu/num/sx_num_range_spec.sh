Describe 'sx_num_range -efu 環境検証'
  Include ./sx.sh

  It '正常動作'

    When run efu_run sx_num_range result 5
    The status should be success
  End
End
