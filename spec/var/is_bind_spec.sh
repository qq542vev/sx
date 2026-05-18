#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_var_is_bind'
    Include ./sx.sh

    It 'validates basic binds'
        When call sx_var_is_bind "a:b:c"
        The status should be success
    End

    It 'validates binds with skips (empty elements)'
        When call sx_var_is_bind "a::c" ":b" "a:" "::"
        The status should be success
    End

    It 'validates single variable name as bind'
        When call sx_var_is_bind "myvar" "_"
        The status should be success
    End

    It 'validates empty string as bind'
        When call sx_var_is_bind ""
        The status should be success
    End

    It 'rejects invalid characters (like hyphen)'
        When call sx_var_is_bind "a-b:c"
        The status should be failure
    End

    It 'rejects elements starting with digits'
        When call sx_var_is_bind "1a:b" "a:2b"
        The status should be failure
    End

    It 'rejects other invalid characters'
        When call sx_var_is_bind "a.b" "a=b" "a b"
        The status should be failure
    End
End
