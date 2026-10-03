Describe 'sx_arr_is_ebind -efu 環境検証'
  Include ./sx.sh

  It '有効な拡張バインドを受け付けること'
    When run efu_run sx_arr_is_ebind 'scalar:0/2list:0/3list'
    The status should be success
  End

  It '上限と同じ割当数を拒否すること'
    When run efu_run sx_arr_is_ebind '2/2list'
    The status should be failure
  End
End
