# shellcheck shell=sh

Describe 'sx_str_is_oct'
  Include ./sx.sh

  It '有効な 8 進数文字列の場合、成功を返すこと'
    When call sx_str_is_oct "01234567"
    The status should be success
  End

  It '単一の有効な 8 進数文字の場合、成功を返すこと'
    When call sx_str_is_oct "0"
    The status should be success
  End

  It '複数の有効な 8 進数文字列の場合、成功を返すこと'
    When call sx_str_is_oct "123" "456" "701"
    The status should be success
  End

  It '空文字列の場合、失敗を返すこと'
    When call sx_str_is_oct ""
    The status should be failure
  End

  It '8 進数以外の数字（8, 9）が含まれる場合、失敗を返すこと'
    When call sx_str_is_oct "8"
    The status should be failure
  End

  It '8 進数以外の数字を含む文字列の場合、失敗を返すこと'
    When call sx_str_is_oct "1283"
    The status should be failure
  End

  It '数字以外の文字が含まれる場合、失敗を返すこと'
    When call sx_str_is_oct "12a3"
    The status should be failure
  End

  It 'スペースが含まれる場合、失敗を返すこと'
    When call sx_str_is_oct " 123"
    The status should be failure
  End

  It '改行が含まれる場合、失敗を返すこと'
    When call sx_str_is_oct "12${SX_STR_LF}3"
    The status should be failure
  End

  It 'いずれかの引数が 8 進数でない場合、失敗を返すこと'
    When call sx_str_is_oct "123" "890" "456"
    The status should be failure
  End

  It '引数がない場合、成功を返すこと'
    When call sx_str_is_oct
    The status should be success
  End
End
