Describe 'sx_num_is_nzint -efu 環境検証'
  Include ./sx.sh

  It '正常動作'

    When run efu_run sx_num_is_nzint "1" "07" "0xABC" "-1"
    The status should be success
  End

  It 'ゼロが含まれる場合の失敗動作'

    When run efu_run sx_num_is_nzint "1" "0" "07"
    The status should be failure
  End
End
