#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_var_is_bindable'
    Include ./sx.sh

    # テスト用の定数定義（SX_EX_USAGE=64）
    readonly TEST_RO="ro_var"
    readonly ro_var="readonly"

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
    End
End
