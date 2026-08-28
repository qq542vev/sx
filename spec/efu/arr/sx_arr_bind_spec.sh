Describe 'sx_arr_bind -efu 環境検証'
  Include ./sx.sh

  It '正常動作'
    br=
    cr=
    When run efu_run sx_arr_bind br cr "a:b:c" v1 v2
    The status should be success
  End

  It 'バインドが空で対象が残っている場合に 1 を返すこと'
    br=
    cr=
    When run efu_run sx_arr_bind br cr "" v1
    The status should equal 1
  End
End