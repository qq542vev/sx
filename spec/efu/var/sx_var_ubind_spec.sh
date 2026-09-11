Describe 'sx_var_ubind -efu 環境検証'
  Include ./sx.sh

  It '正常動作'

    When run efu_run sx_var_ubind res "v1:v2:rest" "val1" "val2" "val3"
    The status should be success
  End

  It 'バインド先の枯渇で 1 を返すこと'

    When run efu_run sx_var_ubind res "v1:" "a" "b"
    The status should equal 1
  End
End
