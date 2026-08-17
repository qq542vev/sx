#!/bin/sh

eval "$(shellspec - -c) exit 1"

# shellcheck shell=sh

Describe 'sx_str_is_punct'
  Include ./sx.sh

  It '区切り記号のみの場合、成功を返すこと'
    When call sx_str_is_punct "!@#"
    The status should be success
  End

  It '単一の区切り記号の場合、成功を返すこと'
    When call sx_str_is_punct "?"
    The status should be success
  End

  It '閉じ括弧などの記号を含む場合、成功を返すこと'
    When call sx_str_is_punct "]}~"
    The status should be success
  End

  It '複数の有効な区切り記号列の場合、成功を返すこと'
    When call sx_str_is_punct "!@#" "?" "]}~"
    The status should be success
  End

  It '英字が含まれる場合、失敗を返すこと'
    When call sx_str_is_punct "!a@"
    The status should be failure
  End

  It '数字が含まれる場合、失敗を返すこと'
    When call sx_str_is_punct "!1@"
    The status should be failure
  End

  It 'スペースが含まれる場合、失敗を返すこと'
    When call sx_str_is_punct "! @"
    The status should be failure
  End

  It '空文字列の場合、失敗を返すこと'
    When call sx_str_is_punct ""
    The status should be failure
  End

  It 'いずれかの引数が区切り記号でない場合、失敗を返すこと'
    When call sx_str_is_punct "!@#" "abc" "]}~"
    The status should be failure
  End

  It '引数がない場合、成功を返すこと'
    When call sx_str_is_punct
    The status should be success
  End

  It '非常に長い区切り記号列（1000桁）を検証できること'
    long_punct=$(printf '!%.0s' $(seq 1 1000))
    When call sx_str_is_punct "${long_punct}"
    The status should be success
  End

  It '多数の引数（10個以上）を一括検証できること'
    When call sx_str_is_punct '!' '@' '#' '$' '%' '^' '&' '*' '(' ')'
    The status should be success
  End
End
