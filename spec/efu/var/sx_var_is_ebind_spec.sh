Describe 'sx_var_is_ebind -efu 環境検証'
  Include ./sx.sh

  It '正常動作'
    When run efu_run sx_var_is_ebind "a:b:c" "0/3a:b"
    The status should be success
  End

  It '無効な形式に対して 1 を返すこと'
    When run efu_run sx_var_is_ebind "1/1a"
    The status should equal 1
  End
End