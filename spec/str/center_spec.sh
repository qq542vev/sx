#!/bin/sh
eval "$(shellspec - -c) exit 1"

Describe 'sx_str_center'
  Include ./sx.sh

  It '正の長さで中央寄せし、余りを右側に振ること (A 4 = -> =A==)'
    When call sx_str_center res "A" 4 "="
    The variable res should equal "=A=="
  End

  It '負の長さで中央寄せし、余りを左側に振ること (A -4 = -> ==A=)'
    When call sx_str_center res "A" -4 "="
    The variable res should equal "==A="
  End

  It '複数文字の埋め込み文字列を使用すること (A 5 xyz -> xyAxy)'
    # 5文字、Aが1文字、パディング4文字。左2、右2。
    # xyz -> xy (左), xyz -> xy (右)
    When call sx_str_center res "A" 5 "xyz"
    The variable res should equal "xyAxy"
  End

  It 'デフォルトでスペースを使用すること (A 3 -> " A ")'
    When call sx_str_center res "A" 3
    The variable res should equal " A "
  End

  It '既に指定された長さ以上の場合はそのまま返すこと'
    When call sx_str_center res "ABCDE" 3 "="
    The variable res should equal "ABCDE"
  End

  It '長さ 0 の場合はそのまま返すこと'
    When call sx_str_center res "ABC" 0 "="
    The variable res should equal "ABC"
  End

  It '結果変数が読み取り専用の場合は NOPERM を返すこと'
    readonly ro_var="init"
    When call sx_str_center ro_var "A" 4
    The status should equal 77
  End

  It '長さが数値でない場合は USAGE を返すこと'
    When call sx_str_center res "A" "invalid"
    The status should equal 64
  End

  It '埋め込み文字列が空の場合は何もしないこと (A 4 "" -> A)'
    When call sx_str_center res "A" 4 ""
    The variable res should equal "A"
    The status should equal 0
  End

  It '非常に大きな幅（1000）で中央寄せできること'
    When call sx_str_center res "x" 1000
    The length of variable res should equal 1000
  End

  It '埋め込み文字にタブを使用できること'
    tab=$(printf '\t')
    When call sx_str_center res "A" 5 "${tab}"
    The variable res should equal "${tab}${tab}A${tab}${tab}"
  End

  It '負の大きな幅で中央寄せできること'
    When call sx_str_center res "A" -1000 "="
    The length of variable res should equal 1000
  End

  It '埋め込み文字列が空で幅不足の場合、元の文字列を返すこと'
    When call sx_str_center res "ABC" 5 ""
    The variable res should equal "ABC"
  End
End
