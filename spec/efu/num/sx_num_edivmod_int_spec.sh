Describe 'sx_num_edivmod_int -efu 環境検証'
  Include ./sx.sh

  It '正常動作'

    When run efu_run sx_num_edivmod_int "q:r:" 100 4
    The status should be success
  End
End
