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

    It 'M/N レンジ指定を許可すること'
        When call sx_var_is_ebind "0/3a:b" "0/1a:b" "0/2b:c"
        The status should be success
    End

    It 'M が 0 の場合を許可すること'
        When call sx_var_is_ebind "0/3a:b" "a:0/2b:c"
        The status should be success
    End

    It '末尾の無限 rest セグメント（分母省略）を許可すること'
        When call sx_var_is_ebind "3/arr" "0/unbounded" "a:3/arr" "3/arr2" "3/_x"
        The status should be success
    End

    It 'rest でも分母あり（M/N）を許可すること（均一化）'
        When call sx_var_is_ebind "3/4a" "x:3/4a" "0/3a"
        The status should be success
    End

    It '中間の分母省略（M/名前）を許可すること'
        When call sx_var_is_ebind "3/arr:b" "a:3/arr:b" "a:3/b:c"
        The status should be success
    End

    It 'M/・M/N の型なしセグメントを許可すること'
        When call sx_var_is_ebind "3/" "3/4" "0/" "a:3/:b"
        The status should be success
    End

    It 'M/@・M/N@ の配列セグメントを許可すること'
        When call sx_var_is_ebind "3/@a" "0/3@a" "3/@a:b" "2/@a:3/@a:x"
        The status should be success
    End

    It '同型での同名再利用を許可すること'
        When call sx_var_is_ebind "2/a:3/a:x" "2/@a:3/@a:x" "a:x:a:y" "a:a" "a:b:a"
        The status should be success
    End

    It '末尾の要素が数字で始まる場合は拒否すること'
        When call sx_var_is_ebind "a:2b" "3" "0" "a:0" "3a" "2b" "1a:b" "3:"
        The status should be failure
    End

    It 'スラッシュなしの数値プレフィックスを拒否すること'
        When call sx_var_is_ebind "1a:b" "12v:x" "v:2v:" "a:2:b" "1a:2:c3:tt4t" "2147483648v:"
        The status should be failure
    End

    It 'スラッシュなしの @ 形式を拒否すること'
        When call sx_var_is_ebind "@arr" "3@a" "a:@arr" "a:10@x" "@" "a:@"
        The status should be failure
    End

    It 'M が N 以上のレンジを拒否すること'
        When call sx_var_is_ebind "1/0a:b" "1/1a:b" "2/1a:b" "5/5a" "3/3a" "0/0a" "10/2a"
        The status should be failure
    End

    It '異なる型での同名再利用を拒否すること'
        When call sx_var_is_ebind "a:3/a" "a:0/3a" "a:3/@a" "2/a:3/@a"
        The status should be failure
    End

    It '先頭に 0 を持つ数値プレフィックスを拒否すること'
        When call sx_var_is_ebind "0:" "a:0:b" "01/a:b" "0b:c" "01/3a" "3/01a" "00/a"
        The status should be failure
    End

    It 'スラッシュを含む不正な形式を拒否すること'
        When call sx_var_is_ebind "/3a" "a:/3b" "a:3b/" "a:b/2c" "3//a" "3/@a@b" "3/4/5a" "1/2/3"
        The status should be failure
    End

    It '大きな値のカウントを許可すること'
        When call sx_var_is_ebind "99999999999999999999999/arr" "0/99999999999999999999999a"
        The status should be success
    End

    It '大きな M/N レンジを許可すること'
        When call sx_var_is_ebind "0/2147483647a:b"
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

        It '新形式を受理すること'
            When call sx_var_is_ebind "3/@a:b"
            The status should be success
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
