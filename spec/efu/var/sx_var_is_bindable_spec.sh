Describe 'sx_var_is_bindable -efu 環境検証'
  Include ./sx.sh

  It '正常動作'

    When run efu_run sx_var_is_bindable "writable" "a:b:c"
    The status should be success
  End

  It '@name が書き込み可能な場合の正常動作'
    efu_writable_arr_case() {
      efu_ok_arr="v"
      sx_var_is_bindable "x:@efu_ok_arr"
    }

    When run efu_run efu_writable_arr_case
    The status should be success
  End

  It '@name が読み取り専用の場合の失敗動作'
    efu_ro_arr_case() {
      readonly efu_ro_arr="v"
      sx_var_is_bindable "x:@efu_ro_arr"
    }

    When run efu_run efu_ro_arr_case
    The status should equal 1
  End
End
