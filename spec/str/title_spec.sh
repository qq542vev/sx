#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_str_title()'
    Include ./sx.sh

    It '各単語の先頭を大文字に、残りを小文字に変換する'
        When call sx_str_title res "aaa bbb ccc"
        The variable res should equal "Aaa Bbb Ccc"
    End

    It '混在した文字列を変換する'
        When call sx_str_title res "hello WORLD"
        The variable res should equal "Hello World"
    End

    It 'アポストロフィを含む単語を正しく処理する'
        When call sx_str_title res "aaa's bbb"
        The variable res should equal "Aaa's Bbb"
    End

    It '数字で始まる単語は変換しない'
        When call sx_str_title res "123abc"
        The variable res should equal "123abc"
    End

    It 'アルファベット以外の文字はそのまま保持する'
        When call sx_str_title res "123!@#"
        The variable res should equal "123!@#"
    End

    It '空文字列を処理する'
        When call sx_str_title res ""
        The variable res should equal ""
    End

    It '全て大文字の文字列を変換する'
        When call sx_str_title res "HELLO"
        The variable res should equal "Hello"
    End

    It '読み取り専用変数に対して EX_NOPERM を返す'
        readonly MYRO_TITLE="const"
        When call sx_str_title MYRO_TITLE "abc"
        The status should be failure
        The status should equal "${SX_EX_NOPERM}"
    End

    It 'カスタム区切り文字で変換する'
        When call sx_str_title res "hello-world_test" "-_"
        The variable res should equal "Hello-World_Test"
    End

    It '先頭に!がある区切り文字セットで正しく動作する'
        When call sx_str_title res "hello!world" "!x"
        The variable res should equal "Hello!World"
    End

    It '途中に]がある区切り文字セットで正しく動作する'
        When call sx_str_title res "hello]world" "a]b"
        The variable res should equal "Hello]World"
    End

    It '途中に-がある区切り文字セットでレンジ誤解釈が起きないこと'
        When call sx_str_title res "abc-def-ghi" "a-z"
        The variable res should equal "Abc-Def-Ghi"
    End

    It '改行区切りの単語を変換できること'
        When call sx_str_title res "hello${SX_STR_LF}world"
        The variable res should equal "Hello${SX_STR_LF}World"
    End
End
