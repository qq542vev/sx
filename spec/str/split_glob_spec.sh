#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_str_split (glob)'
    Include ./sx.sh

    It 'glob パターンによる分割ができること'
        sx_str_split res "a1b2c3d" "[0-9]" "${SX_NUM_I32_MAX}" "${SX_STR_SPLIT_GLOB}"
        Assert sx_str_eq "${res}" "'a' 'b' 'c' 'd'"
    End

    It 'glob パターンによる制限付き前方分割ができること'
        sx_str_split res "a1b2c3d" "[0-9]" 2 "${SX_STR_SPLIT_GLOB}"
        Assert sx_str_eq "${res}" "'a' 'b' 'c3d'"
    End

    It 'glob パターンによる制限付き後方分割ができること'
        sx_str_split res "a1b2c3d" "[0-9]" -2 "${SX_STR_SPLIT_GLOB}"
        Assert sx_str_eq "${res}" "'a1b' 'c' 'd'"
    End

    It '[*] を含むパターンでの分割ができること'
        sx_str_split res "a*b*c" "[*]" "${SX_NUM_I32_MAX}" "${SX_STR_SPLIT_GLOB}"
        Assert sx_str_eq "${res}" "'a' 'b' 'c'"
    End

    It '数字で分割（複数文字）'
        sx_str_split res "abc123def456ghi" "[0-9][0-9][0-9]" "${SX_NUM_I32_MAX}" "${SX_STR_SPLIT_GLOB}"
        Assert sx_str_eq "${res}" "'abc' 'def' 'ghi'"
    End

    It '文字セットでの分割'
        sx_str_split res "a:b;c,d" "[:;,]" "${SX_NUM_I32_MAX}" "${SX_STR_SPLIT_GLOB}"
        Assert sx_str_eq "${res}" "'a' 'b' 'c' 'd'"
    End
End
