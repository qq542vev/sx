Describe 'sx_str_capital()'
    Include ./sx.sh

    It '文頭がアルファベットなら大文字に、残りを小文字に変換する'
        When call sx_str_capital res "aaa bbb ccc"
        The variable res should equal "Aaa bbb ccc"
    End

    It '混在した文字列を変換する（文頭のみ）'
        When call sx_str_capital res "hello WORLD"
        The variable res should equal "Hello world"
    End

    It 'デフォルトでは先頭に空白があると大文字化しない'
        When call sx_str_capital res "  aaa"
        The variable res should equal "  aaa"
    End

    It 'デフォルトでは数字で始まる場合大文字化しない'
        When call sx_str_capital res "123abc"
        The variable res should equal "123abc"
    End

    It 'SENTフラグ：先頭に空白があっても最初のアルファベットを大文字化する'
        When call sx_str_capital res "  aaa" 2147483647 "${SX_STR_CAPITAL_SENT}"
        The variable res should equal "  Aaa"
    End

    It 'SENTフラグ：数字で始まる場合でも最初のアルファベットを大文字化する'
        When call sx_str_capital res "123abc" 2147483647 "${SX_STR_CAPITAL_SENT}"
        The variable res should equal "123Abc"
    End

    It 'KEEPフラグ：最初のアルファベットのみ大文字化し、他は維持する'
        When call sx_str_capital res "hello WORLD" 2147483647 "${SX_STR_CAPITAL_KEEP}"
        The variable res should equal "Hello WORLD"
    End

    It 'KEEPフラグ：既に大文字で始まる場合は何もしない（最適化の確認）'
        When call sx_str_capital res "Hello WORLD" 2147483647 "${SX_STR_CAPITAL_KEEP}"
        The variable res should equal "Hello WORLD"
    End

    It 'KEEPフラグ：文頭が空白の場合、何もしない（SENT無効時）'
        When call sx_str_capital res "  aaa" 2147483647 "${SX_STR_CAPITAL_KEEP}"
        The variable res should equal "  aaa"
    End

    It 'アルファベット以外の文字はそのまま保持する'
        When call sx_str_capital res "123!@#"
        The variable res should equal "123!@#"
    End

    It '空文字列を処理する'
        When call sx_str_capital res ""
        The variable res should equal ""
    End

    It '全て大文字の文字列を変換する'
        When call sx_str_capital res "HELLO"
        The variable res should equal "Hello"
    End

    It '読み取り専用変数に対して EX_NOPERM を返す'
        readonly MYRO_CAP="const"
        When call sx_str_capital MYRO_CAP "abc"
        The status should be failure
        The status should equal "${SX_EX_NOPERM}"
    End

    It 'count=0 では何も変換しない'
        When call sx_str_capital res "hElLo" 0
        The variable res should equal "hElLo"
    End

    It 'count=1 で1文字目の大文字化のみ行い、他は未処理'
        When call sx_str_capital res "hElLo" 1
        The variable res should equal "HElLo"
    End

    It 'count=2 で2文字目の小文字化まで行い、3文字目以降は未処理'
        When call sx_str_capital res "hElLo" 2
        The variable res should equal "HelLo"
    End

    It 'count=4 ですべての文字を変換する'
        When call sx_str_capital res "hElLo" 4
        The variable res should equal "Hello"
    End

    It 'count=1 + SENT で最初のアルファベットのみ大文字化し、残りは未処理'
        When call sx_str_capital res "123abc" 1 "${SX_STR_CAPITAL_SENT}"
        The variable res should equal "123Abc"
    End

    It 'count=2 + SENT で2マッチ目まで処理'
        When call sx_str_capital res "123ABC" 2 "${SX_STR_CAPITAL_SENT}"
        The variable res should equal "123AbC"
    End

    It 'count=3 + SENT で3マッチ目まで処理'
        When call sx_str_capital res "123ABCD" 3 "${SX_STR_CAPITAL_SENT}"
        The variable res should equal "123AbcD"
    End

    It 'count=-1（逆方向）で最後のアルファベットから処理する'
        When call sx_str_capital res "aBc" -1
        The variable res should equal "aBc"
    End

    It 'KEEP+SENT フラグ：先頭空白の場合、最初のアルファベットのみ大文字化'
        When call sx_str_capital res "  hello" "${SX_NUM_I32_MAX}" "$((SX_STR_CAPITAL_KEEP | SX_STR_CAPITAL_SENT))"
        The variable res should equal "  Hello"
    End

    It 'KEEP+SENT フラグ：数字で始まる場合も最初のアルファベットのみ大文字化'
        When call sx_str_capital res "123abc" "${SX_NUM_I32_MAX}" "$((SX_STR_CAPITAL_KEEP | SX_STR_CAPITAL_SENT))"
        The variable res should equal "123Abc"
    End

    It 'KEEP+SENT フラグ：混在ケースで最初のアルファベットのみ大文字化'
        When call sx_str_capital res "hello WORLD" "${SX_NUM_I32_MAX}" "$((SX_STR_CAPITAL_KEEP | SX_STR_CAPITAL_SENT))"
        The variable res should equal "Hello WORLD"
    End

    It 'KEEP+SENT フラグ：先頭がアルファベットの場合'
        When call sx_str_capital res "hello" "${SX_NUM_I32_MAX}" "$((SX_STR_CAPITAL_KEEP | SX_STR_CAPITAL_SENT))"
        The variable res should equal "Hello"
    End

    It 'SENT フラグ：句読点で始まる場合も最初のアルファベットを大文字化する'
        When call sx_str_capital res "!!!hello" "${SX_NUM_I32_MAX}" "${SX_STR_CAPITAL_SENT}"
        The variable res should equal "!!!Hello"
    End

    It 'SENT フラグ：全大文字の文字列を変換する'
        When call sx_str_capital res "HELLO" "${SX_NUM_I32_MAX}" "${SX_STR_CAPITAL_SENT}"
        The variable res should equal "Hello"
    End

    It 'SENT フラグ：単一文字を大文字化する'
        When call sx_str_capital res "a" "${SX_NUM_I32_MAX}" "${SX_STR_CAPITAL_SENT}"
        The variable res should equal "A"
    End

    It 'KEEP フラグ：全大文字の場合は何もしない'
        When call sx_str_capital res "HELLO" "${SX_NUM_I32_MAX}" "${SX_STR_CAPITAL_KEEP}"
        The variable res should equal "HELLO"
    End

    It 'KEEP フラグ：全小文字の場合は最初のみ大文字化'
        When call sx_str_capital res "hello" "${SX_NUM_I32_MAX}" "${SX_STR_CAPITAL_KEEP}"
        The variable res should equal "Hello"
    End

    It 'KEEP フラグ：count=0 では何もしない'
        When call sx_str_capital res "hello" 0 "${SX_STR_CAPITAL_KEEP}"
        The variable res should equal "hello"
    End

    It 'KEEP フラグ：count=1 で最初のアルファベットのみ大文字化'
        When call sx_str_capital res "AaA" 1 "${SX_STR_CAPITAL_KEEP}"
        The variable res should equal "AaA"
    End

    It 'デフォルト：全小文字を変換する'
        When call sx_str_capital res "hello"
        The variable res should equal "Hello"
    End

    It 'デフォルト：単一文字大文字は変化しない'
        When call sx_str_capital res "A"
        The variable res should equal "A"
    End

    It 'デフォルト：単一文字小文字を大文字化する'
        When call sx_str_capital res "a"
        The variable res should equal "A"
    End

    It 'デフォルト：数字のみの文字列は変化しない'
        When call sx_str_capital res "123"
        The variable res should equal "123"
    End

    It 'count に不正な文字列を渡すと EX_USAGE を返す'
        When call sx_str_capital res "abc" "xyz"
        The status should be failure
        The status should equal "${SX_EX_USAGE}"
    End

    It 'flags に不正な文字列を渡すと EX_USAGE を返す'
        When call sx_str_capital res "abc" 1 "xyz"
        The status should be failure
        The status should equal "${SX_EX_USAGE}"
    End

    It '第1引数を省略すると EX_USAGE を返す'
        When call sx_str_capital
        The status should be failure
        The status should equal "${SX_EX_USAGE}"
    End

    It 'KEEP フラグ：先頭が非アルファベット小文字で始まる場合は何もしない（最適化パス）'
        When call sx_str_capital res "1hello" "${SX_NUM_I32_MAX}" "${SX_STR_CAPITAL_KEEP}"
        The variable res should equal "1hello"
    End

    It 'KEEP フラグ：先頭が非アルファベット大文字で始まる場合は何もしない（最適化パス）'
        When call sx_str_capital res "1HELLO" "${SX_NUM_I32_MAX}" "${SX_STR_CAPITAL_KEEP}"
        The variable res should equal "1HELLO"
    End
End
