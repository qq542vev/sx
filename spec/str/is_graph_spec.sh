#!/bin/sh

eval "$(shellspec - -c) exit 1"

# shellcheck shell=sh

Describe 'sx_str_is_graph'
  Include ./sx.sh

  It '英字のみの場合、成功を返すこと'
    When call sx_str_is_graph "abcXYZ"
    The status should be success
  End

  It '数字のみの場合、成功を返すこと'
    When call sx_str_is_graph "123"
    The status should be success
  End

  It '区切り記号のみの場合、成功を返すこと'
    When call sx_str_is_graph "!@#"
    The status should be success
  End

  It '英数字と区切り記号の混在の場合、成功を返すこと'
    When call sx_str_is_graph "abc!@#123"
    The status should be success
  End

  It 'スペースが含まれる場合、失敗を返すこと'
    When call sx_str_is_graph "abc def"
    The status should be failure
  End

  It '改行が含まれる場合、失敗を返すこと'
    When call sx_str_is_graph "abc${SX_STR_LF}def"
    The status should be failure
  End

  It '制御文字が含まれる場合、失敗を返すこと'
    When call sx_str_is_graph "$(printf 'abc\001')"
    The status should be failure
  End

  It '空文字列の場合、失敗を返すこと'
    When call sx_str_is_graph ""
    The status should be failure
  End

  It 'いずれかの引数が図形文字でない場合、失敗を返すこと'
    When call sx_str_is_graph "abc" " " "123"
    The status should be failure
  End

  It '引数がない場合、成功を返すこと'
    When call sx_str_is_graph
    The status should be success
  End

  It '非常に長い図形文字列（1000桁）を検証できること'
    long_graph=$(printf 'a%.0s' $(seq 1 1000))
    When call sx_str_is_graph "${long_graph}"
    The status should be success
  End
End
