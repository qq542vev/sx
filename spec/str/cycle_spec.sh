Describe 'sx_str_cycle()'
    Include ./sx.sh

    It '文字列を指定されたシフト量だけ左方向に循環させる'
        When call sx_str_cycle res "ABCDE" 2
        The variable res should equal "CDEAB"
    End

    It '負のシフトで右方向に循環する'
        When call sx_str_cycle res "ABCDE" -1
        The variable res should equal "EABCD"
    End

    It 'シフト量が文字列長を超える場合は剰余を使用する'
        When call sx_str_cycle res "ABC" 5
        The variable res should equal "CAB"
    End

    It 'シフト0は何も変化させない'
        When call sx_str_cycle res "ABC" 0
        The variable res should equal "ABC"
    End

    It '1文字の文字列は変化しない'
        When call sx_str_cycle res "A" 3
        The variable res should equal "A"
    End

    It '空文字列を処理する'
        When call sx_str_cycle res "" 1
        The variable res should equal ""
    End

    It 'シフト量の指定がない場合は1シフトする'
        When call sx_str_cycle res "ABC"
        The variable res should equal "BCA"
    End

    It '読み取り専用変数に対して EX_NOPERM を返す'
        readonly MYRO_CYC="const"
        When call sx_str_cycle MYRO_CYC "ABC"
        The status should be failure
        The status should equal "${SX_EX_NOPERM}"
    End

    It '不正なシフト量に対して EX_USAGE を返す'
        When call sx_str_cycle res "ABC" "x"
        The status should be failure
        The status should equal "${SX_EX_USAGE}"
    End
End
