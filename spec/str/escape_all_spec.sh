#!/bin/sh

Describe '__sx_str_escape_all'
  sxtest_load ./build/modules/__sx_str_escape_all.sh

  It '各文字を開始文字列と終了文字列で囲む'
    When call __sx_str_escape_all res abc '[' ']'
    The status should be success
    The variable res should equal '[a][b][c]'
  End

  It '空文字列を空のまま設定する'
    res=previous
    When call __sx_str_escape_all res '' '[' ']'
    The status should be success
    The variable res should equal ''
  End

  It '開始文字列と終了文字列を空にすると元文字列を返す'
    When call __sx_str_escape_all res 'a b' '' ''
    The status should be success
    The variable res should equal 'a b'
  End

  It '結果変数と元文字列が同じでも変換できる'
    res=abc
    When call __sx_str_escape_all res "$res" '[' ']'
    The status should be success
    The variable res should equal '[a][b][c]'
  End

  It 'マルチバイト文字を1文字として扱う'
    When call __sx_str_escape_all res 'あa' '[' ']'
    The status should be success
    The variable res should equal '[あ][a]'
  End

  It '引用符や展開記号を含む文字列をデータとして保持する'
    input="a'\"\$\`b"
    expected="[a]['][\"][\$][\`][b]"
    When call __sx_str_escape_all res "$input" '[' ']'
    The status should be success
    The variable res should equal "$expected"
  End
End
