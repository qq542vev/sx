#!/bin/sh

eval "$(shellspec - -c) exit 1"

# shellcheck shell=sh

Describe 'sx_str_is_ascii'
  Include ./sx.sh

  It '英字のみの場合、成功を返すこと'
    When call sx_str_is_ascii "abcXYZ"
    The status should be success
  End

  It '数字のみの場合、成功を返すこと'
    When call sx_str_is_ascii "123"
    The status should be success
  End

  It '区切り記号のみの場合、成功を返すこと'
    When call sx_str_is_ascii "!@#"
    The status should be success
  End

  It '制御文字のみの場合、成功を返すこと'
    When call sx_str_is_ascii "$(printf '\001\002')"
    The status should be success
  End

  It '英数字と区切り記号が混在する場合、成功を返すこと'
    When call sx_str_is_ascii "abc123!@#"
    The status should be success
  End

  It '制御文字と英数字が混在する場合、成功を返すこと'
    When call sx_str_is_ascii "$(printf 'abc\001def')"
    The status should be success
  End

  It 'マルチバイト文字（UTF-8）が含まれる場合、失敗を返すこと'
    When call sx_str_is_ascii "abcあdef"
    The status should be failure
  End

  It '空文字列の場合、失敗を返すこと'
    When call sx_str_is_ascii ""
    The status should be failure
  End

  It 'いずれかの引数がASCII文字でない場合、失敗を返すこと'
    When call sx_str_is_ascii "abc" "$(printf '\200')" "123"
    The status should be failure
  End

  It '引数がない場合、成功を返すこと'
    When call sx_str_is_ascii
    The status should be success
  End

  It '非常に長いASCII文字列（1000桁）を検証できること'
    long_ascii=$(printf 'a%.0s' $(seq 1 1000))
    When call sx_str_is_ascii "${long_ascii}"
    The status should be success
  End
End
