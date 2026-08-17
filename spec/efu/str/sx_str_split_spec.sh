Describe 'sx_str_split -efu 環境検証'
  Include ./sx.sh

  It '正常動作'

    When run efu_run sx_str_split "a:b:rem" "v1:v2:v3:v4" ":"
    The status should be success
  End
End
