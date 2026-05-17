#!/bin/sh
eval "$(shellspec - -c) exit 1"

Describe 'sx_str_pad'
  Include ./sx.sh

  It '正の長さで左側に埋めること (A 3 = -> ==A)'
    When call sx_str_pad res "A" 3 "="
    The variable res should equal "==A"
  End

  It '正の長さで左側に埋めること (A 3 xyz -> xyA)'
    When call sx_str_pad res "A" 3 "xyz"
    The variable res should equal "xyA"
  End

  It '負の長さで右側に埋めること (A -3 xyz -> Axy)'
    When call sx_str_pad res "A" -3 "xyz"
    The variable res should equal "Axy"
  End

  It 'デフォルトでスペースを使用すること (A 3 -> "  A")'
    When call sx_str_pad res "A" 3
    The variable res should equal "  A"
  End

  It '既に指定された長さ以上の場合はそのまま返すこと'
    When call sx_str_pad res "ABCDE" 3 "="
    The variable res should equal "ABCDE"
  End

  It '長さ 0 の場合はそのまま返すこと'
    When call sx_str_pad res "ABC" 0 "="
    The variable res should equal "ABC"
  End
  
  It '埋め込み文字列が複数文字で繰り返しが必要な場合'
    When call sx_str_pad res "A" 5 "xyz"
    The variable res should equal "xyzxA"
  End
  
  It '結果変数が読み取り専用の場合は NOPERM を返すこと'
    readonly ro_var="init"
    When call sx_str_pad ro_var "A" 3
    The status should equal 77
  End

  It '長さが数値でない場合は USAGE を返すこと'
    When call sx_str_pad res "A" "invalid"
    The status should equal 64
  End

  It '埋め込み文字列が空の場合は何もしないこと (A 3 "" -> A)'
    When call sx_str_pad res "A" 3 ""
    The variable res should equal "A"
    The status should equal 0
  End
End
