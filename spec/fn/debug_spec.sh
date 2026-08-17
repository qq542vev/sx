#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_fn_with debug'
  Include ./sx.sh
  It '匿名関数が正しく定義され、置換されていること'
    When call sx_fn_with 'myfn=res=replaced' myfn
    The status should be success
    The variable res should equal "replaced"
  End
End
