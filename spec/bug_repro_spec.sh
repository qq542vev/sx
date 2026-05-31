#!/bin/sh
eval "$(shellspec - -c) exit 1"
Describe "sx_arg_quote bug"
  Include ./sx.sh
  It "breaks with double quotes"
    When call sx_arg_quote res 'a"b'
    The status should be success
    The variable res should equal "'a\"b'"
  End
End
