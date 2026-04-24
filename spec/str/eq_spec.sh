Describe 'sx_str_eq'
  Include ./sx.sh
  It 'すべての引数が等しい場合に成功を返すこと'
    When call sx_str_eq "a" "a" "a"
    The status should be success
  End

  It 'いずれかの引数が異なる場合に失敗を返すこと'
    When call sx_str_eq "a" "a" "b"
    The status should be failure
  End

  It '引数が1つの場合に成功を返すこと'
    When call sx_str_eq "a"
    The status should be success
  End

  It '引数がない場合に成功を返すこと'
    When call sx_str_eq
    The status should be success
  End
End
