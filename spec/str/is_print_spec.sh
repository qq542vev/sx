#!/bin/sh

eval "$(shellspec - -c) exit 1"

# shellcheck shell=sh

Describe 'sx_str_is_print'
  Include ./sx.sh

  It '英字のみの場合、成功を返すこと'
    When call sx_str_is_print "abcXYZ"
    The status should be success
  End

  It '数字のみの場合、成功を返すこと'
    When call sx_str_is_print "123"
    The status should be success
  End

  It '区切り記号のみの場合、成功を返すこと'
    When call sx_str_is_print "!@#"
    The status should be success
  End

  It 'スペースを含む場合、成功を返すこと'
    When call sx_str_is_print "abc def"
    The status should be success
  End

  It '改行が含まれる場合、失敗を返すこと'
    When call sx_str_is_print "abc${SX_STR_LF}def"
    The status should be failure
  End

  It '制御文字が含まれる場合、失敗を返すこと'
    When call sx_str_is_print "$(printf 'abc\001')"
    The status should be failure
  End

  It '空文字列の場合、失敗を返すこと'
    When call sx_str_is_print ""
    The status should be failure
  End

  It 'いずれかの引数が表示可能文字でない場合、失敗を返すこと'
    When call sx_str_is_print "abc" "$(printf '\001')" "123"
    The status should be failure
  End

  It '引数がない場合、成功を返すこと'
    When call sx_str_is_print
    The status should be success
  End

  It '非常に長い表示可能文字列（1000桁）を検証できること'
    long_print=$(printf 'a %.0s' $(seq 1 500))
    When call sx_str_is_print "${long_print}"
    The status should be success
  End
End
