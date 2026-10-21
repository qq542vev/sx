Describe 'sx_str_sub -efu 環境検証'
  Include ./spec/support/library.sh spec/efu/str/sx_str_sub_spec.sh __sx_var_set sx_str_sub

  It '正常動作'

    When run efu_run sx_str_sub result: "hello world" "world" "earth"
    The status should be success
  End

  Context '巨大な正負の回数制限'
    Parameters
      999999999999999999999999999999 a X 0
      -999999999999999999999999999999 '[a]' X 1
      -9223372036854775808 a efu_cb_set2 2
      999999999999999999999999999999 '[a]' efu_cb_set2 3
      '' '' X 0
      -999999999999999999999999999999 '*' efu_cb_set2 3
      -0 '' efu_cb_true 2
    End

    It '厳格モードで算術エラーや変数漏洩なく完了すること'
      verify_sub() {
        sx_str_sub result:cnt aba "$2" "$3" "$1" "$4"
        check_no_leak
      }
      When run efu_run verify_sub "$1" "$2" "$3" "$4"
      The status should be success
    End
  End
End
