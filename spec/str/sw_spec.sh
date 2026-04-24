Describe 'sx_str_sw'
  Include ./sx.sh
  It '第1引数がそれ以降のいずれかの引数で始まる場合に成功を返すこと'
    When call sx_str_sw "hello world" "hell"
    The status should be success
  End

  It 'いずれの引数でも始まらない場合に失敗を返すこと'
    When call sx_str_sw "hello world" "world"
    The status should be failure
  End
End
