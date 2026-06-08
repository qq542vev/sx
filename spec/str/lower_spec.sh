Describe 'sx_str_lower()'
    Include ./sx.sh

    It '大文字を小文字に変換する'
        When call sx_str_lower res "ABC"
        The variable res should equal "abc"
    End

    It '小文字はそのまま保持する'
        When call sx_str_lower res "abc"
        The variable res should equal "abc"
    End

    It '混在した文字列を変換する'
        When call sx_str_lower res "Hello WORLD"
        The variable res should equal "hello world"
    End

    It 'アルファベット以外の文字はそのまま保持する'
        When call sx_str_lower res "123!@#"
        The variable res should equal "123!@#"
    End

    It '空文字列を処理する'
        When call sx_str_lower res ""
        The variable res should equal ""
    End

    Context '回数制限あり'
        It '前方からの変換回数を制限する'
            When call sx_str_lower res "ABCDEF" 2
            The variable res should equal "abCDEF"
        End

        It '後方からの変換回数を制限する'
            When call sx_str_lower res "ABCDEF" -2
            The variable res should equal "ABCDef"
        End
    End

    It '不正な回数制限に対して EX_USAGE を返す'
        When call sx_str_lower res "ABC" "x"
        The status should be failure
        The status should equal "${SX_EX_USAGE}"
    End

    It '読み取り専用変数に対して EX_NOPERM を返す'
        readonly MYRO_LOWER="const"
        When call sx_str_lower MYRO_LOWER "ABC"
        The status should be failure
        The status should equal "${SX_EX_NOPERM}"
    End
End
