Describe 'sx_str_isep -efu 環境検証'
  sxtest_load ./build/modules/sx_str_isep.sh

  It '正常動作'

    When run efu_run sx_str_isep res: "123456" "-" 2
    The status should be success
  End
End
