#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_var_bind_init'
    Include ./sx.sh

    It 'initializes variables in a:b:rest format'
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

    It 'initializes a single variable to empty string'
        v1="old"
        When call sx_var_bind_init "v1"
        The status should be success
        The variable v1 should equal ""
    End

    It 'skips empty slots in schema'
        v1="old1"
        v2="old2"
        When call sx_var_bind_init "v1::v2"
        The status should be success
        The variable v1 should be undefined
        The variable v2 should equal ""
    End

    It 'properly unsets SX Arrays'
        sx_arr_gen arr a b
        When call sx_var_bind_init "arr:rest"
        The status should be success
        The variable arr should be undefined
        The variable arr_len should be undefined
        The variable arr_0 should be undefined
        The variable rest should equal ""
    End

    It 'properly initializes last variable if it was an SX Array'
        sx_arr_gen arr a b
        When call sx_var_bind_init "arr"
        The status should be success
        The variable arr should equal ""
        The variable arr_len should be undefined
        The variable arr_0 should be undefined
    End

    It 'returns EX_USAGE for invalid binding schema'
        When call sx_var_bind_init "invalid-name!"
        The status should equal 64 # SX_EX_USAGE
    End

    It 'returns EX_NOPERM for read-only variables'
        readonly TEST_RO_INIT="ro"
        When call sx_var_bind_init "a:TEST_RO_INIT:c"
        The status should equal 77 # SX_EX_NOPERM
    End

    It 'handles multiple schemas'
        v1="a" v2="b" v3="c" v4="d"
        When call sx_var_bind_init "v1:v2" "v3:v4"
        The status should be success
        The variable v1 should be undefined
        The variable v2 should equal ""
        The variable v3 should be undefined
        The variable v4 should equal ""
    End
End
