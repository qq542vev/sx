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
