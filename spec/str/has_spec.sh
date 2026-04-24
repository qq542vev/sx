Describe 'sx_str_has'
  Include ./sx.sh
  It '第1引数がそれ以降のいずれかの引数を含む場合に成功を返すこと'
    When call sx_str_has "hello world" "world"
    The status should be success
  End

  It '一致するものが見つからない場合に失敗を返すこと'
    When call sx_str_has "hello world" "earth"
    The status should be failure
  End

  It '空文字列を検索した場合に成功を返すこと'
    When call sx_str_has "hello" ""
    The status should be success
  End
End
