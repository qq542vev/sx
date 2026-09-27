Describe 'sx_num_divfloor_int -efu 環境検証'
  Include ./sx.sh

  It '正常動作'

    When run efu_run sx_num_divfloor_int q -100 3
    The status should be success
  End
End
