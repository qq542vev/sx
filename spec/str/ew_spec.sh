Describe 'sx_str_ew'
  Include ./sx.sh
  It '第1引数がそれ以降のいずれかの引数で終わる場合に成功を返すこと'
    When call sx_str_ew "hello world" "world"
    The status should be success
  End

  It 'いずれの引数でも終わらない場合に失敗を返すこと'
    When call sx_str_ew "hello world" "hell"
    The status should be failure
  End
End
