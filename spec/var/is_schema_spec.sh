#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_var_is_schema'
    Include ./sx.sh

    It 'validates basic schemas'
        When call sx_var_is_schema "a:b:c"
        The status should be success
    End

    It 'validates schemas with skips (empty elements)'
        When call sx_var_is_schema "a::c" ":b" "a:" "::"
        The status should be success
    End

    It 'validates single variable name as schema'
        When call sx_var_is_schema "myvar" "_"
        The status should be success
    End

    It 'validates empty string as schema'
        When call sx_var_is_schema ""
        The status should be success
    End

    It 'rejects invalid characters (like hyphen)'
        When call sx_var_is_schema "a-b:c"
        The status should be failure
    End

    It 'rejects elements starting with digits'
        When call sx_var_is_schema "1a:b" "a:2b"
        The status should be failure
    End

    It 'rejects other invalid characters'
        When call sx_var_is_schema "a.b" "a=b" "a b"
        The status should be failure
    End
End
