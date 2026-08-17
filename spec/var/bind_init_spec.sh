#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_var_bind_init'
    Include ./sx.sh

    It 'a:b:rest 形式で変数を初期化すること'
        v1="old1"
        v2="old2"
        v3="old3"
        v4="old4"
        When call sx_var_bind_init "v1:v2:v3:v4"
        The status should be success
        The variable v1 should be undefined
        The variable v2 should be undefined
        The variable v3 should be undefined
        The variable v4 should equal ""
    End

    It '単一の変数を空文字列で初期化すること'
        v1="old"
        When call sx_var_bind_init "v1"
        The status should be success
        The variable v1 should equal ""
    End

    It 'スキーマ内の空のスロットをスキップすること'
        v1="old1"
        v2="old2"
        When call sx_var_bind_init "v1::v2"
        The status should be success
        The variable v1 should be undefined
        The variable v2 should equal ""
    End

    It 'SX 配列を適切に unset すること'
        sx_arr_gen arr a b
        When call sx_var_bind_init "arr:rest"
        The status should be success
        The variable arr should be undefined
        The variable arr_len should be undefined
        The variable arr_0 should be undefined
        The variable rest should equal ""
    End

    It '最後の変数が SX 配列だった場合に適切に初期化すること'
        sx_arr_gen arr a b
        When call sx_var_bind_init "arr"
        The status should be success
        The variable arr should equal ""
        The variable arr_len should be undefined
        The variable arr_0 should be undefined
    End

    It '無効なバインディングスキーマに対して EX_USAGE を返すこと'
        When call sx_var_bind_init "invalid-name!"
        The status should equal 64 # SX_EX_USAGE
    End

    It '読み取り専用変数に対して EX_NOPERM を返すこと'
        readonly TEST_RO_INIT="ro"
        When call sx_var_bind_init "a:TEST_RO_INIT:c"
        The status should equal 77 # SX_EX_NOPERM
    End

    It '複数のスキーマを処理できること'
        v1="a" v2="b" v3="c" v4="d"
        When call sx_var_bind_init "v1:v2" "v3:v4"
        The status should be success
        The variable v1 should be undefined
        The variable v2 should equal ""
        The variable v3 should be undefined
        The variable v4 should equal ""
    End
End
