#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_str_split (glob)'
    Include ./spec/support/library.sh sx_str_split

    It 'glob パターンによる分割ができること'
        When call sx_str_split res "a1b2c3d" "[0-9]" 2147483647 "${SX_STR_SPLIT_GLOB}"
        The status should be success
        The variable res should equal "'a' 'b' 'c' 'd'"
    End

    It 'glob パターンによる制限付き前方分割ができること'
        When call sx_str_split res "a1b2c3d" "[0-9]" 2 "${SX_STR_SPLIT_GLOB}"
        The status should be success
        The variable res should equal "'a' 'b' 'c3d'"
    End

    It 'glob パターンによる制限付き後方分割ができること'
        When call sx_str_split res "a1b2c3d" "[0-9]" -2 "${SX_STR_SPLIT_GLOB}"
        The status should be success
        The variable res should equal "'a1b' 'c' 'd'"
    End

    It '[*] を含むパターンでの分割ができること'
        When call sx_str_split res "a*b*c" "[*]" 2147483647 "${SX_STR_SPLIT_GLOB}"
        The status should be success
        The variable res should equal "'a' 'b' 'c'"
    End

    It '数字で分割（複数文字）'
        When call sx_str_split res "abc123def456ghi" "[0-9][0-9][0-9]" 2147483647 "${SX_STR_SPLIT_GLOB}"
        The status should be success
        The variable res should equal "'abc' 'def' 'ghi'"
    End

    It '文字セットでの分割'
        When call sx_str_split res "a:b;c,d" "[:;,]" 2147483647 "${SX_STR_SPLIT_GLOB}"
        The status should be success
        The variable res should equal "'a' 'b' 'c' 'd'"
    End
End
