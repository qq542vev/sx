Describe "sx_num_is_pint"
  It "returns 0 for positive integers"
    . ./sx.sh
    sx_num_is_pint 1
    # 成功を確認
    [ $? -eq 0 ]
  End

  It "returns 1 for 0"
    . ./sx.sh
    sx_num_is_pint 0
    # 1であることを確認
    [ $? -eq 1 ]
  End

  It "returns 1 for negative integers"
    . ./sx.sh
    sx_num_is_pint -1
    [ $? -eq 1 ]
  End
End
Describe 'sx_num_is_pint'
  Include ./sx.sh

  Context '有効な入力'
    It '単一の有効な正の整数に対して成功を返すこと'
      When call sx_num_is_pint "1"
      The status should be success
    End

    It '複数の有効な正の整数に対して成功を返すこと'
      When call sx_num_is_pint "1" "123" "456789"
      The status should be success
    End

    It '非常に大きな数値に対して成功を返すこと'
      When call sx_num_is_pint "9223372036854775807"
      The status should be success
    End
  End

  Context '無効な入力 - ゼロ'
    It 'ゼロに対して失敗を返すこと'
      When call sx_num_is_pint "0"
      The status should be failure
    End

    It '複数のゼロを持つ数値に対して失敗を返すこと'
      When call sx_num_is_pint "0" "00"
      The status should be failure
    End

    It '有効な数値とゼロの組み合わせに対して失敗を返すこと'
      When call sx_num_is_pint "123" "0"
      The status should be failure
    End
  End

  Context '無効な入力 - 先頭ゼロ'
    It '先頭に0がある数値に対して失敗を返すこと'
      When call sx_num_is_pint "01"
      The status should be failure
    End

    It '複数の先頭ゼロを持つ数値に対して失敗を返すこと'
      When call sx_num_is_pint "001" "000"
      The status should be failure
    End

    It '有効な数値と先頭ゼロを持つ数値の組み合わせに対して失敗を返すこと'
      When call sx_num_is_pint "123" "045"
      The status should be failure
    End
  End

  Context '無効な入力 - 非数字文字'
    It '英字を含む数値に対して失敗を返すこと'
      When call sx_num_is_pint "123a"
      The status should be failure
    End

    It '記号を含む数値に対して失敗を返すこと'
      When call sx_num_is_pint "123@"
      The status should be failure
    End

    It '空白を含む数値に対して失敗を返すこと'
      When call sx_num_is_pint "12 3"
      The status should be failure
    End

    It '複数の非数字文字を含む数値に対して失敗を返すこと'
      When call sx_num_is_pint "a1b2c3"
      The status should be failure
    End
  End

  Context '無効な入力 - 空文字列'
    It '空文字列に対して失敗を返すこと'
      When call sx_num_is_pint ""
      The status should be failure
    End

    It '空文字列と有効な数値の組み合わせに対して失敗を返すこと'
      When call sx_num_is_pint "" "123"
      The status should be failure
    End
  End

  Context '無効な入力 - 負の数値'
    It '負の数値に対して失敗を返すこと'
      When call sx_num_is_pint "-1"
      The status should be failure
    End

    It '負のゼロに対して失敗を返すこと'
      When call sx_num_is_pint "-0"
      The status should be failure
    End

    It '複数の負の数値に対して失敗を返すこと'
      When call sx_num_is_pint "-1" "-2" "-3"
      The status should be failure
    End
  End

  Context '無効な入力 - 符号付き数値'
    It 'プラス記号付きの数値に対して失敗を返すこと'
      When call sx_num_is_pint "+1"
      The status should be failure
    End

    It 'プラス記号付きのゼロに対して失敗を返すこと'
      When call sx_num_is_pint "+0"
      The status should be failure
    End
  End

  Context '無効な入力 - 浮動小数点数'
    It '小数点を含む数値に対して失敗を返すこと'
      When call sx_num_is_pint "1.23"
      The status should be failure
    End

    It '指数表記の数値に対して失敗を返すこと'
      When call sx_num_is_pint "1e3"
      The status should be failure
    End
  End

  Context '複合的な無効な入力'
    It '有効な数値と無効な数値の組み合わせに対して失敗を返すこと'
      When call sx_num_is_pint "123" "45a" "789"
      The status should be failure
    End

    It 'すべての引数が無効な場合に対して失敗を返すこと'
      When call sx_num_is_pint "abc" "12.3" "-456"
      The status should be failure
    End
  End

  Context '境界値テスト'
    It '最小値（1）に対して成功を返すこと'
      When call sx_num_is_pint "1"
      The status should be success
    End

    It '最大値（64bit符号付き整数の最大値）に対して成功を返すこと'
      When call sx_num_is_pint "9223372036854775807"
      The status should be success
    End

    It '最大値より1大きい数値に対して失敗を返すこと'
      When call sx_num_is_pint "9223372036854775808"
      The status should be failure
    End
  End
End
