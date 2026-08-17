#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_str_rot()'
    Include ./sx.sh

    It '大文字のみ ROT13 が機能する'
        When call sx_str_rot res "HELLO" "${SX_STR_UPPER}" 13
        The variable res should equal "URYYB"
    End

    It '小文字のみ ROT13 が機能する'
        When call sx_str_rot res "hello" "${SX_STR_LOWER}" 13
        The variable res should equal "uryyb"
    End

    It '大文字のみ ROT13 でシフト量が文字セット長を超える場合は剰余を使用する'
        When call sx_str_rot res "HELLO" "${SX_STR_UPPER}" 39
        The variable res should equal "URYYB"
    End

    It 'デフォルト（SX_STR_ALPHA, 13シフト）で大文字は小文字領域にマップされる'
        When call sx_str_rot res "HELLO"
        The variable res should equal "URYYb"
    End

    It 'デフォルトで小文字は大文字領域にマップされる'
        When call sx_str_rot res "hello"
        The variable res should equal "uryyB"
    End

    It 'アルファベット以外の文字はそのまま保持する'
        When call sx_str_rot res "123!@#"
        The variable res should equal "123!@#"
    End

    It '任意の文字セットでシフトできる'
        When call sx_str_rot res "135" "${SX_STR_DIGIT}" 3
        The variable res should equal "468"
    End

    It '負のシフトが機能する'
        When call sx_str_rot res "BC" "${SX_STR_UPPER}" -1
        The variable res should equal "AB"
    End

    It 'シフト0は何も変換しない'
        When call sx_str_rot res "ABC" "${SX_STR_UPPER}" 0
        The variable res should equal "ABC"
    End

    It '空の文字セットは元の文字列をそのまま返す'
        When call sx_str_rot res "HELLO" ""
        The variable res should equal "HELLO"
    End

    It '空文字列を処理する'
        When call sx_str_rot res ""
        The variable res should equal ""
    End

    It '読み取り専用変数に対して EX_NOPERM を返す'
        readonly MYRO_ROT="const"
        When call sx_str_rot MYRO_ROT "ABC"
        The status should be failure
        The status should equal "${SX_EX_NOPERM}"
    End

    It '不正なシフト量に対して EX_USAGE を返す'
        When call sx_str_rot res "ABC" "${SX_STR_UPPER}" "x"
        The status should be failure
        The status should equal "${SX_EX_USAGE}"
    End
End
