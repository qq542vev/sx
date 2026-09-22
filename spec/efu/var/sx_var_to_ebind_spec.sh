Describe 'sx_var_to_ebind -efu 環境検証'
  Include ./sx.sh

  It '正常動作'
    When run efu_run sx_var_to_ebind res '2:3a:b:9@c:2a:2d::d'
    The status should be success
  End

  It '引数不正で64を返すこと'
    When run efu_run sx_var_to_ebind res 'a:2b'
    The status should equal 64
  End
End
