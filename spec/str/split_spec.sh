Describe 'sx_str_split'
  Include ./sx.sh
  It '文字列を分割して結果変数に格納すること'
    When call sx_str_split res "a:b:c:d" ":"
    The status should be success
    The variable res should equal "'a' 'b' 'c' 'd'"
  End

  It '回数制限付きで前方から分割すること'
    When call sx_str_split res "a:b:c:d" ":" 2
    The status should be success
    The variable res should equal "'a' 'b' 'c:d'"
  End

  It '回数制限付きで後方から分割すること'
    When call sx_str_split res "a:b:c:d" ":" -2
    The status should be success
    The variable res should equal "'a:b' 'c' 'd'"
  End

  It '特殊文字を処理できること'
    When call sx_str_split res "a'b:c\"d" ":" 1
    The status should be success
    The variable res should equal "'a'\''b' 'c\"d'"
  End

  It '空の入力文字列を処理できること'
    When call sx_str_split res "" ":" 5
    The status should be success
    The variable res should equal "''"
  End

  It '空文字を区切り文字とした場合に境界線モデルで分割すること'
    When call sx_str_split res "abcde" ""
    The status should be success
    The variable res should equal "'' 'a' 'b' 'c' 'd' 'e' ''"
  End

  It '空文字を区切り文字として制限付きで前方から分割すること'
    When call sx_str_split res "abcde" "" 3
    The status should be success
    The variable res should equal "'' 'a' 'b' 'cde'"
  End

  It '空文字を区切り文字として制限付きで後方から分割すること'
    When call sx_str_split res "abcde" "" -3
    The status should be success
    The variable res should equal "'abc' 'd' 'e' ''"
  End

  It '空文字を空文字で分割した場合に2つの要素を返すこと'
    When call sx_str_split res "" ""
    The status should be success
    The variable res should equal "'' ''"
  End
End
