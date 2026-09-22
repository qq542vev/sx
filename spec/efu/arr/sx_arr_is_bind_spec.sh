Describe 'sx_arr_is_bind -efu 環境検証'
  Include ./sx.sh

  It '正常動作'
    When run efu_run sx_arr_is_bind "a:b:c"
    The status should be success
  End

  It '引数なしで成功すること'
    When run efu_run sx_arr_is_bind
    The status should be success
  End

  It '@ を含む形式を拒否すること'
    When run efu_run sx_arr_is_bind "a:@arr"
    The status should be failure
  End
End
