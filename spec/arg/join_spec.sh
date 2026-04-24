Describe 'sx_arg_join'
  Include ./sx.sh
  It '引数を区切り文字で結合すること'
    When call sx_arg_join result ":" "a" "b" "c"
    The status should be success
    The variable result should equal "a:b:c"
  End

  It '空の区切り文字を処理できること'
    When call sx_arg_join result "" "a" "b" "c"
    The status should be success
    The variable result should equal "abc"
  End

  It '引数がない場合を処理できること'
    When call sx_arg_join result ":"
    The status should be success
    The variable result should equal ""
  End
End
