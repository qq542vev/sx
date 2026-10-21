Describe 'sx_str_isep -efu 環境検証'
  Include ./spec/support/library.sh spec/efu/str/sx_str_isep_spec.sh sx_str_isep

  It '正常動作'

    When run efu_run sx_str_isep res: "123456" "-" 2
    The status should be success
  End
End
