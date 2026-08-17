#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_str_swapcase()'
    Include ./sx.sh

    It '大文字を小文字に変換する'
        When call sx_str_swapcase res "ABC"
        The variable res should equal "abc"
    End

    It '小文字を大文字に変換する'
        When call sx_str_swapcase res "abc"
        The variable res should equal "ABC"
    End

    It '混在した文字列を反転する'
        When call sx_str_swapcase res "Hello WORLD"
        The variable res should equal "hELLO world"
    End

    It 'アルファベット以外の文字はそのまま保持する'
        When call sx_str_swapcase res "123!@#"
        The variable res should equal "123!@#"
    End

    It '空文字列を処理する'
        When call sx_str_swapcase res ""
        The variable res should equal ""
    End

    Context '回数制限あり'
        It '前方からの変換回数を制限する'
            When call sx_str_swapcase res "AbCdEf" 2
            The variable res should equal "aBCdEf"
        End

        It '後方からの変換回数を制限する'
            When call sx_str_swapcase res "AbCdEf" -2
            The variable res should equal "AbCdeF"
        End
    End

    It '不正な回数制限に対して EX_USAGE を返す'
        When call sx_str_swapcase res "ABC" "x"
        The status should be failure
        The status should equal "${SX_EX_USAGE}"
    End

    It '読み取り専用変数に対して EX_NOPERM を返す'
        readonly MYRO_SWAP="const"
        When call sx_str_swapcase MYRO_SWAP "ABC"
        The status should be failure
        The status should equal "${SX_EX_NOPERM}"
    End

    It 'count=0では何も変換しないこと'
        When call sx_str_swapcase res "AbC" 0
        The variable res should equal "AbC"
    End

    It 'countが文字列長を超えても全変換されること'
        When call sx_str_swapcase res "AbC" 10
        The variable res should equal "aBc"
    End

    It 'アルファベットが存在しない文字列は何もしないこと'
        When call sx_str_swapcase res "123!@#"
        The variable res should equal "123!@#"
    End
End
