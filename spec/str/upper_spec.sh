#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_str_upper()'
    Include ./sx.sh

    It '小文字を大文字に変換する'
        When call sx_str_upper res "abc"
        The variable res should equal "ABC"
    End

    It '大文字はそのまま保持する'
        When call sx_str_upper res "ABC"
        The variable res should equal "ABC"
    End

    It '混在した文字列を変換する'
        When call sx_str_upper res "Hello world"
        The variable res should equal "HELLO WORLD"
    End

    It 'アルファベット以外の文字はそのまま保持する'
        When call sx_str_upper res "123!@#"
        The variable res should equal "123!@#"
    End

    It '空文字列を処理する'
        When call sx_str_upper res ""
        The variable res should equal ""
    End

    Context '回数制限あり'
        It '前方からの変換回数を制限する'
            When call sx_str_upper res "abcdef" 2
            The variable res should equal "ABcdef"
        End

        It '後方からの変換回数を制限する'
            When call sx_str_upper res "abcdef" -2
            The variable res should equal "abcdEF"
        End
    End

    It '不正な回数制限に対して EX_USAGE を返す'
        When call sx_str_upper res "abc" "x"
        The status should be failure
        The status should equal "${SX_EX_USAGE}"
    End

    It '読み取り専用変数に対して EX_NOPERM を返す'
        readonly MYRO_UPPER="const"
        When call sx_str_upper MYRO_UPPER "abc"
        The status should be failure
        The status should equal "${SX_EX_NOPERM}"
    End

    It 'count=0では何も変換しないこと'
        When call sx_str_upper res "abc" 0
        The variable res should equal "abc"
    End

    It 'countが文字列長を超えても全変換されること'
        When call sx_str_upper res "aBc" 10
        The variable res should equal "ABC"
    End

    It 'アルファベットが存在しない文字列は何もしないこと'
        When call sx_str_upper res "123!@#"
        The variable res should equal "123!@#"
    End
End
