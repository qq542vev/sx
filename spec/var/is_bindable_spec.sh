#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_var_is_bindable'
    Include ./sx.sh

    # テスト用の定数定義（SX_EX_USAGE=64）
    readonly TEST_RO="ro_var"
    readonly ro_var="readonly"

    It 'returns success for valid binds with writable variables'
        writable="value"
        When call sx_var_is_bindable "writable" "a:b:c"
        The status should be success
    End

    It 'returns EX_USAGE (64) for invalid bind syntax'
        When call sx_var_is_bindable "invalid-name" "a b c" "1abc"
        The status should equal 64
    End

    It 'returns failure (1) if any variable in bind is readonly'
        When call sx_var_is_bindable "TEST_RO"
        The status should equal 1
    End

    It 'returns failure (1) if a nested variable in bind is readonly'
        When call sx_var_is_bindable "a:TEST_RO:c"
        The status should equal 1
    End

    It 'handles skip elements (::) correctly'
        When call sx_var_is_bindable "a::c" ":b" "a:"
        The status should be success
    End

    It 'returns failure (1) even with skips if other variables are readonly'
        When call sx_var_is_bindable "::TEST_RO"
        The status should equal 1
    End

    It 'returns success for empty string (valid but empty bind)'
        When call sx_var_is_bindable ""
        The status should be success
    End

    Context 'when SX_CFG_SKIP_CHK is 1'
        BeforeRun 'SX_CFG_SKIP_CHK=1'

        It 'skips syntax check and performs direct permission check'
            # 妥当な形式で、書き込み可能な変数を確認
            writable="ok"
            When call sx_var_is_bindable "writable"
            The status should be success
        End

        It 'still returns failure (1) for readonly variables'
            When call sx_var_is_bindable "TEST_RO"
            The status should equal 1
        End
    End
End
