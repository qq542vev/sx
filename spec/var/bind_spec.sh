#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_var_bind'
    Include ./sx.sh

    Describe '基本動作'
        It '単純な代入を実行し、状態を更新すること'
            unset v1 v2 rest res
            When call sx_var_bind res "v1:v2:rest" "val1"
            The status should be success
            The variable v1 should equal "val1"
            The variable res should equal "v2:rest"
        End

        It '複数の値を一度に割り当てること'
            unset v1 v2 rest res
            When call sx_var_bind res "v1:v2:rest" "a" "b" "c"
            The status should be success
            The variable v1 should equal "a"
            The variable v2 should equal "b"
            The variable rest should equal "'c'"
            The variable res should equal "rest"
        End

        It 'スキップスロットを正しく処理すること'
            unset v2 rest res
            When call sx_var_bind res ":v2:rest" "discarded" "val2"
            The status should be success
            The variable v2 should equal "val2"
            The variable res should equal "rest"
        End

        It 'カウント指定代入を処理すること'
            unset arr res
            When call sx_var_bind res "2arr:rest" "a1" "a2"
            The status should be success
            The variable arr should equal "'a1' 'a2'"
            The variable res should equal "rest"
        End

        It 'データが不足している場合に残りのバインド状態を保持すること'
            unset arr res
            When call sx_var_bind res "3arr:rest" "a1"
            The status should be success
            The variable arr should equal "'a1'"
            The variable res should equal "2arr:rest"
        End

        It 'カウントスロットが bind 未到達でも空文字列として参照できること'
            unset b c
            sx_var_bind_init "a:2b:c"
            When call sx_var_bind res "a:2b:c" "val1"
            The status should be success
            eval set -- "${b}"
            The value "$#" should equal 0
        End

        It '残り（rest）スロットに累積すること'
            unset out res
            When call sx_var_bind res "out" "a1" "a2"
            The status should be success
            The variable out should equal "'a1' 'a2'"
            The variable res should equal "out"
        End

        It 'スロットが尽きた場合に 1 を返し、結果変数に空のバインド形式が書き込まれること'
            unset v1 res
            res="unchanged"
            When call sx_var_bind res "v1:" "a" "b"
            The status should equal 1
            The variable v1 should equal "a"
            The variable res should equal ""
        End

        It 'データが無い場合にバインド状態を結果に書き込んで成功すること'
            unset res
            When call sx_var_bind res "v1:rest"
            The status should be success
            The variable res should equal "v1:rest"
        End
    End

    Describe 'クォート動作'
        It '代入スロットは生の値、蓄積スロットはクォートされること'
            unset arr out res
            When call sx_var_bind res "arr:out" "it's me" "don't stop"
            The status should be success
            The variable arr should equal "it's me"
            The variable out should equal "'don'\''t stop'"
        End

        It 'カウント指定でもクォートが適用されること'
            unset arr res
            When call sx_var_bind res "2arr:rest" "a'b" "c d"
            The status should be success
            The variable arr should equal "'a'\''b' 'c d'"
        End
    End

    Describe 'バリデーション'
        It '結果変数が読み取り専用の場合に EX_NOPERM (77) を返すこと'
            readonly RO_RES=""
            When call sx_var_bind RO_RES "v1:v2" "val"
            The status should equal 77
        End

        It 'バインド仕様に含まれる変数が読み取り専用の場合に EX_NOPERM (77) を返すこと'
            readonly RO_TARGET="fixed"
            When call sx_var_bind res "RO_TARGET:rest" "val"
            The status should equal 77
        End

        It '不正な変数名に対して EX_USAGE (64) を返すこと'
            When call sx_var_bind res "invalid-name:rest" "val"
            The status should equal 64
        End

        It '設定エラー (EX_CONFIG: 78) を検知すること'
            check_config() {
                SX_CFG_NUM_RANGE=99
                sx_var_bind res "v1:rest" "val"
            }
            When call check_config
            The status should equal 78
        End
    End
End
