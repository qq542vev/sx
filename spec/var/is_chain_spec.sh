Describe 'sx_var_is_chain'
  Include ./sx.sh

  It '有効な右方向連鎖式に対して成功を返すこと'
    When call sx_var_is_chain "a-b-c"
    The status should be success
  End

  It '有効な左方向連鎖式に対して成功を返すこと'
    When call sx_var_is_chain "a=b=c"
    The status should be success
  End

  It '単一の有効な変数名に対して成功を返すこと'
    When call sx_var_is_chain "myvar"
    The status should be success
  End

  It '無効な文字を含む場合に失敗を返すこと'
    When call sx_var_is_chain "a+b" "a-b*c"
    The status should be failure
  End

  It '連鎖式が不完全な場合に失敗を返すこと'
    When call sx_var_is_chain "a-" "-b" "a=" "=b"
    The status should be failure
  End

  It '連鎖記号が混在している場合に失敗を返すこと'
    # Actually sx_var_is_chain implementation seems to only check one type at a time
    # but let's see how it behaves with "a-b=c"
    When call sx_var_is_chain "a-b=c"
    The status should be failure
  End

  It '先頭が数字の場合に失敗を返すこと'
    When call sx_var_is_chain "1a-b" "a-1b"
    The status should be failure
  End

  It '空文字列に対して失敗を返すこと'
    When call sx_var_is_chain ""
    The status should be failure
  End
End
