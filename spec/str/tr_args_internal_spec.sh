#!/bin/sh
# shellcheck shell=sh disable=SC2154

Describe '__sx_str_tr_args'
  sxtest_load ./build/modules/__sx_str_tr_args.sh

  It '区切りなしの対応表を共通実装へ渡すこと'
    When call __sx_str_tr_args res:cnt ab ab AA BB
    The status should be success
    The variable res should equal AABB
    The variable cnt should equal "'2'"
  End

  It 'limit省略の区切り形式を共通実装へ渡すこと'
    When call __sx_str_tr_args res:cnt ab ab ::: AA BB
    The status should be success
    The variable res should equal AABB
    The variable cnt should equal "'2'"
  End

  It '負のlimitを共通実装へ渡すこと'
    When call __sx_str_tr_args res:cnt ab ab -1 ::: AA BB
    The status should be success
    The variable res should equal aBB
    The variable cnt should equal "'1'"
  End
End
