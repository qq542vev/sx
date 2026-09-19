Describe 'sx_arr_splice -efu 環境検証'
  Include ./sx.sh

  It '正常動作'
    sx_arr_gen myarr a b c d

    When run efu_run sx_arr_splice myarr 1 2 X Y
    The status should be success
  End
End
