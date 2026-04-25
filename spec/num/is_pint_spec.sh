Describe 'sx_num_is_pint'
  Include ./sx.sh

  Context '有効な入力'
    It '符号なしの正の整数に対して成功を返すこと'
      When call sx_num_is_pint "1" "123"
      The status should be success
    End

    It 'プラス符号付きの正の整数に対して成功を返すこと'
      When call sx_num_is_pint "+1" "+123"
      The status should be success
    End
  End

  Context '無効な入力 - ゼロ'
    It '符号なしのゼロに対して失敗を返すこと'
      When call sx_num_is_pint "0"
      The status should be failure
    End

    It '符号付きのゼロに対して失敗を返すこと'
      When call sx_num_is_pint "+0" "-0"
      The status should be failure
    End
  End

  Context '無効な入力 - 負の数値'
    It '負の数値に対して失敗を返すこと'
      When call sx_num_is_pint "-1" "-123"
      The status should be failure
    End
  End

  Context '無効な入力 - 先頭ゼロ'
    It '先頭に0がある数値に対して失敗を返すこと'
      When call sx_num_is_pint "01" "+01"
      The status should be failure
    End
  End
End
