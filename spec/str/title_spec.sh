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

    Context '回数制限あり'
        It '前方1回の制限で最初のアルファベットのみ大文字化する'
            When call sx_str_title res "abc def" 1
            The variable res should equal "Abc def"
        End

        It '後方1回の制限で最後の単語の先頭を大文字化する'
            When call sx_str_title res "abc d" -1
            The variable res should equal "abc D"
        End
    End

    It '不正な回数制限に対して EX_USAGE を返す'
        When call sx_str_title res "abc" "x"
        The status should be failure
        The status should equal "${SX_EX_USAGE}"
    End

    It '読み取り専用変数に対して EX_NOPERM を返す'
        readonly MYRO_TITLE="const"
        When call sx_str_title MYRO_TITLE "abc"
        The status should be failure
        The status should equal "${SX_EX_NOPERM}"
    End

    It 'カスタム区切り文字で変換する'
        When call sx_str_title res "hello-world_test" "" "[-_]"
        The variable res should equal "Hello-World_Test"
    End

    It 'count=0では何も変換しないこと'
        When call sx_str_title res "abc def" 0
        The variable res should equal "abc def"
    End

    It 'countが単語数を超えても全単語変換されること'
        When call sx_str_title res "a b c" 10
        The variable res should equal "A B C"
    End

    It '改行区切りの単語を変換できること'
        When call sx_str_title res "hello${SX_STR_LF}world"
        The variable res should equal "Hello${SX_STR_LF}World"
    End
End
