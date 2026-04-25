Describe 'sx_num_is_nint'
  Include ./sx.sh

  Context '有効な入力'
    It 'マイナス符号付きの負の整数に対して成功を返すこと'
      When call sx_num_is_nint "-1" "-123"
      The status should be success
    End
  End

  Context '無効な入力 - ゼロ'
    It 'ゼロに対して失敗を返すこと'
      When call sx_num_is_nint "0" "+0" "-0"
      The status should be failure
    End
  End

  Context '無効な入力 - 正の数値'
    It '正の数値に対して失敗を返すこと'
      When call sx_num_is_nint "1" "+1"
      The status should be failure
    End
  End

  Context '無効な入力 - 符号なし'
    It '符号のない数値に対して失敗を返すこと'
      When call sx_num_is_nint "1" "123"
      The status should be failure
    End
  End

  Context '無効な入力 - 先頭ゼロ'
    It '符号の後に先頭ゼロがある場合に失敗を返すこと'
      When call sx_num_is_nint "-01"
      The status should be failure
    End
  End
End
