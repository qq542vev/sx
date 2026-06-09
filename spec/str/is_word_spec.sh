#!/bin/sh

eval "$(shellspec - -c) exit 1"

# shellcheck shell=sh

Describe 'sx_str_is_word'
  Include ./sx.sh

  It '単語構成文字のみを含む文字列の場合、成功を返すこと'
    When call sx_str_is_word "abc_123" "_ABC" "abc"
    The status should be success
  End

  It '単一の単語構成文字の場合、成功を返すこと'
    When call sx_str_is_word "_"
    The status should be success
  End

  It 'ハイフンが含まれる場合、失敗を返すこと'
    When call sx_str_is_word "abc-def"
    The status should be failure
  End

  It 'ドットが含まれる場合、失敗を返すこと'
    When call sx_str_is_word "abc.def"
    The status should be failure
  End

  It '空文字列の場合、失敗を返すこと'
    When call sx_str_is_word ""
    The status should be failure
  End

  It 'スペースが含まれる場合、失敗を返すこと'
    When call sx_str_is_word "abc def"
    The status should be failure
  End

  It '改行が含まれる場合、失敗を返すこと'
    When call sx_str_is_word "ab${SX_STR_LF}c"
    The status should be failure
  End

  It 'いずれかの引数が単語構成文字でない場合、失敗を返すこと'
    When call sx_str_is_word "abc" "def!" "123"
    The status should be failure
  End

  It '引数がない場合、成功を返すこと'
    When call sx_str_is_word
    The status should be success
  End

  It '非常に長い単語構成文字列（1000桁）を検証できること'
    long_word=$(printf 'a_%.0s' $(seq 1 500))
    When call sx_str_is_word "${long_word}"
    The status should be success
  End

  It '多数の引数（10個以上）を一括検証できること'
    When call sx_str_is_word _ a b c 1 2 3 x y z
    The status should be success
  End
End
