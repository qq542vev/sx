Describe 'sx_var_ubind -efu 環境検証'
  Include ./sx.sh

  It '正常動作'
    efu_ubind_ok() {
      sx_var_bind_init "v1:v2:rest"
      sx_var_ubind res "v1:v2:rest" "val1" "val2" "val3"
    }

    When run efu_run efu_ubind_ok
    The status should be success
  End

  It 'バインド先の枯渇で 1 を返すこと'
    efu_ubind_exhaust() {
      sx_var_bind_init "v1:"
      sx_var_ubind res "v1:" "a" "b"
    }

    When run efu_run efu_ubind_exhaust
    The status should equal 1
  End
End
