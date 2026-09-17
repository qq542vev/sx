Describe 'sx_var_bind -efu 環境検証'
  Include ./sx.sh

  It '正常動作'
    efu_bind_ok() {
      sx_var_bind_init "v1:v2:rest"
      sx_var_bind res "v1:v2:rest" "val1" "val2" "val3"
    }

    When run efu_run efu_bind_ok
    The status should be success
  End

  It 'バインド先の枯渇で 1 を返すこと'
    efu_bind_exhaust() {
      sx_var_bind_init "v1:"
      sx_var_bind res "v1:" "a" "b"
    }

    When run efu_run efu_bind_exhaust
    The status should equal 1
  End

  It '@name への分配が正常動作すること'
    efu_bind_arr() {
      sx_var_bind_init "x:@e_arr"
      sx_var_bind res "x:@e_arr" "v1" "v2" "v3"
    }

    When run efu_run efu_bind_arr
    The status should be success
  End

  It '空結果変数で残りを破棄できること'
    efu_bind_empty() {
      sx_var_bind_init "e1:e2:erest"
      sx_var_bind "" "e1:e2:erest" "a"
    }

    When run efu_run efu_bind_empty
    The status should be success
  End

  It '空結果変数で枯渇時に 1 を返すこと'
    efu_bind_empty_exhaust() {
      sx_var_bind_init "e3:"
      sx_var_bind "" "e3:" "a" "b"
    }

    When run efu_run efu_bind_empty_exhaust
    The status should equal 1
  End
End
