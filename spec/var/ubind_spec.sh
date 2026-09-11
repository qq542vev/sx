#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_var_ubind'
    Include ./sx.sh

    Describe '基本動作'
        It '蓄積スロットにクォートなしで累積すること'
            unset out res
            When call sx_var_ubind res "out" "a1" "a2"
            The status should be success
            The variable out should equal "a1 a2"
            The variable res should equal "out"
        End

        It 'カウント指定で複数の値を順に蓄積すること'
            unset arr res
            When call sx_var_ubind res "2arr:rest" "a1" "a2"
            The status should be success
            The variable arr should equal "a1 a2"
            The variable res should equal "rest"
        End

        It '代入スロットと蓄積スロットが混在しても生の値になること'
            unset arr out res
            When call sx_var_ubind res "arr:out" "it's me" "don't stop"
            The status should be success
            The variable arr should equal "it's me"
            The variable out should equal "don't stop"
        End

        It '先頭の蓄積値が空文字列の場合もセパレータを付加しないこと'
            unset b res
            When call sx_var_ubind res "2b:rest" "" "x"
            The status should be success
            The variable b should equal "x"
        End

        It 'データが不足している場合に残りのバインド状態を保持すること'
            unset arr res
            When call sx_var_ubind res "3arr:rest" "a1"
            The status should be success
            The variable arr should equal "a1"
            The variable res should equal "2arr:rest"
        End

        It 'データが無い場合にバインド状態を結果に書き込んで成功すること'
            unset res
            When call sx_var_ubind res "v1:rest"
            The status should be success
            The variable res should equal "v1:rest"
        End

        It 'カウントが 2^64 を超えても正しく減算できること'
            unset arr res
            When call sx_var_ubind res "18446744073709551615arr:rest" "a1" "a2"
            The status should be success
            The variable arr should equal "a1 a2"
            The variable res should equal "18446744073709551613arr:rest"
        End

        It 'スロットが尽きた場合に 1 を返すこと'
            unset v1 res
            res="unchanged"
            When call sx_var_ubind res "v1:" "a" "b"
            The status should equal 1
            The variable v1 should equal "a"
            The variable res should equal "unchanged"
        End
    End

    Describe 'バリデーション'
        It '結果変数が読み取り専用の場合に EX_NOPERM (77) を返すこと'
            readonly RO_RES=""
            When call sx_var_ubind RO_RES "v1:v2" "val"
            The status should equal 77
        End

        It '不正な変数名に対して EX_USAGE (64) を返すこと'
            When call sx_var_ubind res "invalid-name:rest" "val"
            The status should equal 64
        End

        It '設定エラー (EX_CONFIG: 78) を検知すること'
            check_config() {
                SX_CFG_NUM_RANGE=99
                sx_var_ubind res "v1:rest" "val"
            }
            When call check_config
            The status should equal 78
        End
    End
End