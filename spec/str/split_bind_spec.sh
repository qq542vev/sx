#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_str_split bind'
  Include ./sx.sh

  It '前方分割でバインドができること'
    When call sx_str_split "a:b:rem" "v1:v2:v3:v4" ":"
    The status should be success
    The variable a should equal "v1"
    The variable b should equal "v2"
    The variable rem should equal "'v3' 'v4'"
  End

  It '後方分割でバインドができること'
    When call sx_str_split "rem:c:d" "v1:v2:v3:v4" ":" -2
    The status should be success
    The variable c should equal "v3"
    # 最後の変数は常にクォートされたリストになる
    The variable d should equal "'v4'"
    # 途中の変数は生の値になる
    The variable rem should equal "v1:v2"
  End

  It '空区切り（文字単位）でバインドができること'
    # 境界線モデル: '' 'a' 'b' 'c' ''
    When call sx_str_split "a:b:c:rem" "abc" ""
    The status should be success
    The variable a should equal ""
    The variable b should equal "a"
    The variable c should equal "b"
    # 最後の変数は残りのリスト ('c' '')
    The variable rem should equal "'c' ''"
  End

  It 'セパレータを含める場合にバインドができること'
    # limit=0 は分割なし。文字列全体が第1変数に代入されるが、
    # スキーマに : があるため、a は「途中」扱いとなり生の値が入る。
    When call sx_str_split "a:rem" "v1:v2" ":" 0
    The status should be success
    The variable a should equal "v1:v2"
    The variable rem should equal ""
  End

  It 'グロブ分割でバインドができること'
    # limit=0 は分割なし。
    When call sx_str_split "a:b:rem" "v1:v2;v3" "[:;]" 0 "${SX_STR_SPLIT_GLOB}"
    The status should be success
    The variable a should equal "v1:v2;v3"
    The variable b should be undefined
    The variable rem should equal ""
  End

  It 'バインド変数が余る場合、余った変数は空（最後の変数）または未設定になること'
    v1=old v2=old v3=old
    When call sx_str_split "v1:v2:v3" "a" ":"
    The status should be success
    The variable v1 should equal "a"
    The variable v2 should be undefined
    # bind_init は最後の変数を "" で初期化する
    The variable v3 should equal ""
  End
End
