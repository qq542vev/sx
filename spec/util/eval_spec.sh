Describe 'sx_util_eval'
  Include ./sx.sh

  It '文字列をシェルコマンドとして実行すること'
    When call sx_util_eval 'result=success'
    The variable result should equal 'success'
  End

  It '実行したコマンドの終了ステータスを返すこと'
    When call sx_util_eval 'return 42'
    The status should equal 42
  End

  It '複雑なコマンドを実行できること'
    When call sx_util_eval 'for i in 1 2 3; do :; done'
    The status should be success
  End
End
