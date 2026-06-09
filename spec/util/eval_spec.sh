#!/bin/sh

eval "$(shellspec - -c) exit 1"

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
    When call sx_util_eval "for i in 1 2 3; do :; done"
    The status should be success
  End

  It '複数のコマンドを&&で連結して実行できること'
    r=0
    When call sx_util_eval "r=1 && r=2 && r=3"
    The status should be success
    The variable r should equal 3
  End

  It '空文字列を評価した場合に成功を返すこと'
    When call sx_util_eval ""
    The status should be success
  End

  It '変数への代入を含むコマンドを実行できること'
    When call sx_util_eval "eval_result=42"
    The status should be success
    The variable eval_result should equal 42
  End

  It '終了ステータスが保持されること（非ゼロ）'
    When call sx_util_eval "return 42"
    The status should equal 42
  End
End
