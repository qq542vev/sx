#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_var_is_ebind'
    Include ./sx.sh

    It '基本的なバインドを検証すること'
        When call sx_var_is_ebind "a:b:c"
        The status should be success
    End

    It 'スキップ（空の要素）を含むバインドを検証すること'
        When call sx_var_is_ebind "a::c" ":b" "a:" "::"
        The status should be success
    End

    It '単一の変数名をバインドとして検証すること'
        When call sx_var_is_ebind "myvar" "_"
        The status should be success
    End

    It '空文字列をバインドとして検証すること'
        When call sx_var_is_ebind ""
        The status should be success
    End

    It '無効な文字（ハイフンなど）を拒否すること'
        When call sx_var_is_ebind "a-b:c" "a.b" "a=b" "a b"
        The status should be failure
    End

    It '数値プレフィックス付きの要素を許可すること'
        When call sx_var_is_ebind "1a:b" "3:" "v:2v:" "3name"
        The status should be success
    End

    It 'M/N レンジ指定を許可すること'
        When call sx_var_is_ebind "0/3a:b" "3a:0/2b:c" "0/1a:b"
        The status should be success
    End

    It 'M が 0 の場合を許可すること'
        When call sx_var_is_ebind "0/3a" "a:0/2b:c"
        The status should be success
    End

    It '末尾の要素が数字で始まる場合は拒否すること'
        When call sx_var_is_ebind "a:2b" "3" "3a:1/2"
        The status should be failure
    End

    It 'M が N 以上のレンジを拒否すること'
        When call sx_var_is_ebind "1/0a:b" "1/1a:b" "2/1a:b" "5/5a"
        The status should be failure
    End

    It '先頭に 0 を持つ数値プレフィックスを拒否すること'
        When call sx_var_is_ebind "0:" "a:0:b" "01a:b" "0b:c" "01/3a"
        The status should be failure
    End

    It 'スラッシュを含む不正な形式を拒否すること'
        When call sx_var_is_ebind "/3a" "0/" "a:/3b" "a:3b/" "a:b/2c"
        The status should be failure
    End

    It '複数桁のカウントを許可すること'
        When call sx_var_is_ebind "12v:x" "999999999v:"
        The status should be success
    End

    It '裸のカウンタを許可すること'
        When call sx_var_is_ebind "a:2:b"
        The status should be success
    End

    It '変数名中間の数字をカウントとみなさないこと'
        When call sx_var_is_ebind "1a:2:c3:tt4t"
        The status should be success
    End

    It 'SX_CFG_NUM_RANGE を超えるカウントを拒否すること'
        When call sx_var_is_ebind "2147483648v:" "99999999999999999999999v:" "0/2147483648a"
        The status should be failure
    End

    It 'SX_CFG_NUM_RANGE の境界値のカウントを許可すること'
        When call sx_var_is_ebind "2147483647v:" "0/2147483647a"
        The status should be success
    End

    Context 'SX_CFG_SKIP_CHK が 1 のとき'
        BeforeRun 'SX_CFG_SKIP_CHK=1'

        It '無効な形式を拒否すること'
            When call sx_var_is_ebind "a-b:c"
            The status should be failure
        End

        It 'M が N 以上のレンジを拒否すること'
            When call sx_var_is_ebind "1/1a"
            The status should be failure
        End
    End

    Context 'SX_CFG_NUM_RANGE が不正のとき'
        It 'EX_CONFIG (78) を返すこと'
            check_config() {
                SX_CFG_NUM_RANGE=99
                sx_var_is_ebind "a:b"
            }
            When call check_config
            The status should equal 78
        End
    End
End