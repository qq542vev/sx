# shellcheck shell=sh

Describe 'sx_str_is_num'
  Include ./sx.sh

  It '数字のみを含む文字列の場合、成功を返すこと'
    When call sx_str_is_num "123" "0" "456"
    The status should be success
  End

  It '単一の数字の場合、成功を返すこと'
    When call sx_str_is_num "5"
    The status should be success
  End

  It '数字以外の文字を含む文字列の場合、失敗を返すこと'
    When call sx_str_is_num "123a"
    The status should be failure
  End

  It '符号が含まれる場合、失敗を返すこと（sx_str_is_num は純粋な数字のみ）'
    When call sx_str_is_num "+123" "-456"
    The status should be failure
  End

  It '空文字列の場合、失敗を返すこと'
    When call sx_str_is_num ""
    The status should be failure
  End

  It 'スペースが含まれる場合、失敗を返すこと'
    When call sx_str_is_num " 123"
    The status should be failure
  End

  It '改行が含まれる場合、失敗を返すこと'
    When call sx_str_is_num "12${SX_CHAR_LF}3"
    The status should be failure
  End

  It 'いずれかの引数が数字でない場合、失敗を返すこと'
    When call sx_str_is_num "123" "abc" "456"
    The status should be failure
  End

  It '引数がない場合、成功を返すこと'
    When call sx_str_is_num
    The status should be success
  End
End
