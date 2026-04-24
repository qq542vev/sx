Describe 'sx_num_is_digit'
  Include ./sx.sh
  It '数字のみを含む文字列に対して成功を返すこと'
    When call sx_num_is_digit "123" "0" "456"
    The status should be success
  End

  It '数字以外の文字を含む文字列に対して失敗を返すこと'
    When call sx_num_is_digit "123a"
    The status should be failure
  End

  It '空文字列に対して失敗を返すこと'
    When call sx_num_is_digit ""
    The status should be failure
  End
End
