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

    It '先頭に 0 を持つカウントを拒否すること'
        When call sx_var_is_bind "0:" "a:0:b" "01a:b" "a:00b:c" "a:0b:c"
        The status should be failure
    End

    It '複数桁のカウントを許可すること'
        When call sx_var_is_bind "12v:x" "999999999v:"
        The status should be success
    End

    It '裸のカウンタを許可すること'
        When call sx_var_is_bind "a:2:b"
        The status should be success
    End

    It '変数名中間の数字をカウントとみなさないこと'
        When call sx_var_is_bind "1a:2:c3:tt4t"
        The status should be success
    End

    It 'SX_CFG_NUM_RANGE を超えるカウントを拒否すること'
        When call sx_var_is_bind "2147483648v:" "99999999999999999999999v:"
        The status should be failure
    End

    It 'SX_CFG_NUM_RANGE の境界値のカウントを許可すること'
        When call sx_var_is_bind "2147483647v:"
        The status should be success
    End
End
