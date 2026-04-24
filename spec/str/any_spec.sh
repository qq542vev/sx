Describe 'sx_str_any'
  Include ./sx.sh
  It '第1引数がそれ以降のいずれかの引数と一致する場合に成功を返すこと'
    When call sx_str_any "a" "x" "a" "y"
    The status should be success
  End

  It '一致するものが見つからない場合に失敗を返すこと'
    When call sx_str_any "a" "x" "y" "z"
    The status should be failure
  End

  It '引数が1つしか指定されていない場合に失敗を返すこと'
    When call sx_str_any "a"
    The status should be failure
  End
End
