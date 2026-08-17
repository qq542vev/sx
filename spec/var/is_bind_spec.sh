#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_var_is_bind'
    Include ./sx.sh

    It '基本的なバインドを検証すること'
        When call sx_var_is_bind "a:b:c"
        The status should be success
    End

    It 'スキップ（空の要素）を含むバインドを検証すること'
        When call sx_var_is_bind "a::c" ":b" "a:" "::"
        The status should be success
    End

    It '単一の変数名をバインドとして検証すること'
        When call sx_var_is_bind "myvar" "_"
        The status should be success
    End

    It '空文字列をバインドとして検証すること'
        When call sx_var_is_bind ""
        The status should be success
    End

    It '無効な文字（ハイフンなど）を拒否すること'
        When call sx_var_is_bind "a-b:c"
        The status should be failure
    End

    It '数字で始まる要素を許可または拒否すること'
        When call sx_var_is_bind "1a:b" "3:" "v:2v:"
        The status should be success
    End

    It '末尾の要素が数字で始まる場合は拒否すること'
        When call sx_var_is_bind "a:2b" "3"
        The status should be failure
    End

    It 'その他の無効な文字を拒否すること'
        When call sx_var_is_bind "a.b" "a=b" "a b"
        The status should be failure
    End
End
