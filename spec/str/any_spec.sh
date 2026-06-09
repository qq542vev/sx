#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_str_any'
  Include ./sx.sh
  It '第1引数がそれ以降のいずれかの引数と一致する場合に成功を返すこと'
    When call sx_str_any "a" "x" "a" "y"
    The status should be success
  End

  It '一致するものが見つからない場合に失敗を返すこと'
    When call sx_str_any "a" "x" "y" "z"
    The status should be failure
  End

  It '引数が1つしか指定されていない場合に失敗を返すこと'
    When call sx_str_any "a"
    The status should be failure
  End

  It '空文字列が後続のいずれかの空文字列に一致すること'
    When call sx_str_any "" "a" "" "b"
    The status should be success
  End

  It '空文字列が後続の非空文字列に一致しないこと'
    When call sx_str_any "" "a" "b"
    The status should be failure
  End

  It 'グロブ文字*をリテラルとして完全一致できること'
    When call sx_str_any "*" "x" "*"
    The status should be success
  End

  It 'グロブ文字?をリテラルとして完全一致できること'
    When call sx_str_any "?" "x" "?"
    The status should be success
  End

  It '多数の引数（10個以上）から正しく一致を見つけること'
    When call sx_str_any "z" a b c d e f g h i j k "z"
    The status should be success
  End

  It '非常に長い文字列を完全一致できること'
    long_str=$(printf 'a%.0s' $(seq 1 1000))
    When call sx_str_any "${long_str}" "x" "${long_str}"
    The status should be success
  End
End
