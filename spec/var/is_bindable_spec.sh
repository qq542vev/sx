#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_var_is_bindable'
    Include ./sx.sh

    # テスト用の定数定義（SX_EX_USAGE=64）
    readonly TEST_RO="ro_var"
    readonly ro_var="readonly"
    readonly t_ro_arr="v"
    readonly t_ro_arr2_len="0"
    readonly t_ro_arr3="v"
    readonly bd_ro_u="v"
    readonly bd_ro_n="v"
    readonly bd_ro_e_0="v"
    readonly bd_ok_px="v"

    It '書き込み可能な変数を持つ有効なバインドに対して成功を返すこと'
        writable="value"
        When call sx_var_is_bindable "writable" "a:b:c"
        The status should be success
    End

    It '無効なバインド構文に対して EX_USAGE (64) を返すこと'
        When call sx_var_is_bindable "invalid-name" "a b c" "1abc"
        The status should equal 64
    End

    It 'バインド内のいずれかの変数が読み取り専用の場合に失敗 (1) を返すこと'
        When call sx_var_is_bindable "TEST_RO"
        The status should equal 1
    End

    It 'バインド内のネストされた変数が読み取り専用の場合に失敗 (1) を返すこと'
        When call sx_var_is_bindable "a:TEST_RO:c"
        The status should equal 1
    End

    It 'スキップ要素 (::) を正しく処理すること'
        When call sx_var_is_bindable "a::c" ":b" "a:"
        The status should be success
    End

    It 'スキップがあっても他の変数が読み取り専用なら失敗 (1) を返すこと'
        When call sx_var_is_bindable "::TEST_RO"
        The status should equal 1
    End

    It '空文字列（有効だが空のバインド）に対して成功を返すこと'
        When call sx_var_is_bindable ""
        The status should be success
    End

    Describe '数値プレフィックス (list)'
        It '書き込み可能な N名前 に対して成功を返すこと'
            wlst="v"
            When call sx_var_is_bindable "2wlst:x"
            The status should be success
        End

        It 'N名前 の対象が読み取り専用の場合に失敗 (1) を返すこと'
            When call sx_var_is_bindable "2TEST_RO:x"
            The status should equal 1
        End

        It '裸の数値セグメントをスキップとして成功を返すこと'
            sk_a="v" sk_b="v"
            When call sx_var_is_bindable "sk_a:2:sk_b"
            The status should be success
        End

        It '先頭が _ の変数名に対して成功を返すこと'
            _priv="v"
            When call sx_var_is_bindable "_priv:x"
            The status should be success
        End

        It '先頭が _ の変数名が読み取り専用の場合に失敗 (1) を返すこと'
            When call sx_var_is_bindable "a:bd_ro_u:c"
            The status should equal 1
        End

        It '大きなカウント値を含むバインドに対して成功を返すこと'
            biglst="v"
            When call sx_var_is_bindable "99999biglst:x"
            The status should be success
        End
    End

    Describe '構文拒否 (EX_USAGE)'
        It '先頭 0 のカウントに対して EX_USAGE (64) を返すこと'
            When call sx_var_is_bindable "a:01b:c"
            The status should equal 64
        End

        It '末尾の数字始まり要素に対して EX_USAGE (64) を返すこと'
            When call sx_var_is_bindable "a:2b"
            The status should equal 64
        End

        It '単独の数字に対して EX_USAGE (64) を返すこと'
            When call sx_var_is_bindable "3"
            The status should equal 64
        End

        It '数字名の @name に対して EX_USAGE (64) を返すこと'
            When call sx_var_is_bindable "@1:x"
            The status should equal 64
        End

        It 'bare @ に対して EX_USAGE (64) を返すこと'
            When call sx_var_is_bindable "@"
            The status should equal 64
        End

        It '末尾 @ に対して EX_USAGE (64) を返すこと'
            When call sx_var_is_bindable "a:@"
            The status should equal 64
        End

        It '末尾 N@name に対して EX_USAGE (64) を返すこと'
            When call sx_var_is_bindable "a:2@b"
            The status should equal 64
        End
    End

    Describe '@ 記法（配列マーカー）'
        It '書き込み可能な @name に対して成功を返すこと'
            ok_arr="v"
            When call sx_var_is_bindable "x:@ok_arr"
            The status should be success
        End

        It '配列本体が読み取り専用の場合に失敗 (1) を返すこと'
            When call sx_var_is_bindable "x:@t_ro_arr"
            The status should equal 1
        End

        It '配列の _len のみが読み取り専用の場合に失敗 (1) を返すこと'
            When call sx_var_is_bindable "x:@t_ro_arr2"
            The status should equal 1
        End

        It 'N@name 中間形で配列本体が読み取り専用の場合に失敗 (1) を返すこと'
            When call sx_var_is_bindable "a:2@t_ro_arr3:b"
            The status should equal 1
        End

        It 'N@name 中間形で書き込み可能な場合に成功を返すこと'
            ok_arr2="v"
            When call sx_var_is_bindable "a:2@ok_arr2:b"
            The status should be success
        End

        It '複数の @name がすべて書き込み可能の場合に成功を返すこと'
            m1="v" m2="v" m3="v"
            When call sx_var_is_bindable "2@m1:3@m2:@m3"
            The status should be success
        End

        It '中間の N@name の対象が読み取り専用の場合に失敗 (1) を返すこと'
            mc_a="v" mc_c="v"
            When call sx_var_is_bindable "2@mc_a:3@bd_ro_n:@mc_c"
            The status should equal 1
        End

        It '配列要素 (_0) のみが読み取り専用の場合に失敗 (1) を返すこと'
            When call sx_var_is_bindable "x:@bd_ro_e"
            The status should equal 1
        End

        It '名前が前方一致する無関係な読み取り専用変数があっても成功を返すこと'
            bd_ok_p="v"
            When call sx_var_is_bindable "@bd_ok_p"
            The status should be success
        End

        It '空セグメントと @name の混在で書き込み可能な場合に成功を返すこと'
            When call sx_var_is_bindable "a::@ok_arr"
            The status should be success
        End

        It '空セグメントと読み取り専用 @name の混在で失敗 (1) を返すこと'
            When call sx_var_is_bindable "::@t_ro_arr"
            The status should equal 1
        End

        It '複数引数で同名 @name が書き込み可能の場合に成功を返すこと'
            When call sx_var_is_bindable "@ok_arr" "@ok_arr"
            The status should be success
        End
    End

    Describe '複合・複数引数'
        It '通常変数が読み取り専用で @name が書き込み可能の場合に失敗 (1) を返すこと'
            When call sx_var_is_bindable "TEST_RO:@ok_arr"
            The status should equal 1
        End

        It '通常変数が書き込み可能で @name が読み取り専用の場合に失敗 (1) を返すこと'
            mx_ok="v"
            When call sx_var_is_bindable "mx_ok:@t_ro_arr"
            The status should equal 1
        End

        It '複数引数の後方に読み取り専用 @name がある場合に失敗 (1) を返すこと'
            When call sx_var_is_bindable "a:b" "x:@t_ro_arr"
            The status should equal 1
        End

        It '複数引数がすべて書き込み可能な場合に成功を返すこと'
            When call sx_var_is_bindable "@ok_arr" "a:b:c"
            The status should be success
        End
    End

    Describe '境界'
        It '引数なしに対して成功を返すこと'
            When call sx_var_is_bindable
            The status should be success
        End

        It 'SX_CFG_NUM_RANGE が不正でも成功すること'
            check_invalid_config_bindable() {
                SX_CFG_NUM_RANGE=99
                sx_var_is_bindable "a:b"
            }
            When call check_invalid_config_bindable
            The status should be success
        End
    End

    Context 'SX_CFG_SKIP_CHK が 1 のとき'
        BeforeRun 'SX_CFG_SKIP_CHK=1'

        It '構文チェックをスキップして直接的な権限チェックを実行すること'
            # 妥当な形式で、書き込み可能な変数を確認
            writable="ok"
            When call sx_var_is_bindable "writable"
            The status should be success
        End

        It '読み取り専用変数に対しては依然として失敗 (1) を返すこと'
            When call sx_var_is_bindable "TEST_RO"
            The status should equal 1
        End

        It '読み取り専用 @name に対しては依然として失敗 (1) を返すこと'
            When call sx_var_is_bindable "x:@TEST_RO"
            The status should equal 1
        End

        It '書き込み可能な @name に対して成功を返すこと'
            sk_ok="ok"
            When call sx_var_is_bindable "x:@sk_ok"
            The status should be success
        End

        It '数値プレフィックス付きの読み取り専用変数に対しては依然として失敗 (1) を返すこと'
            When call sx_var_is_bindable "2TEST_RO:x"
            The status should equal 1
        End
    End
End
