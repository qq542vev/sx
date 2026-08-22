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

        It 'スキップスロットを正しく処理すること'
            unset v2 rest res
            # 1ステップ目 (skip)
            sx_var_bind res ":v2:rest" "val1"
            # 2ステップ目 (assignment to v2)
            When call sx_var_bind res "$res" "val2"
            The status should be success
            The variable v2 should equal "val2"
            The variable res should equal "rest"
        End

        It 'カウント指定代入を処理すること'
            unset arr rest res
            # 1つ目
            sx_var_bind res "2arr:rest" "a1"
            # 2つ目
            When call sx_var_bind res "$res" "a2"
            The status should be success
            The variable res should equal "rest"
            The variable arr should equal "a1 a2"
        End

        It 'カウントスロットが bind 未到達でも空文字列として参照できること'
            unset b c
            sx_var_bind_init "a:2b:c"
            When call sx_var_bind res "a:2b:c" "val1"
            The status should be success
            eval set -- "${b}"
            The value "$#" should equal 0
        End

        It '先頭の蓄積値が空文字列の場合もセパレータを付加しないこと'
            unset b rest res
            sx_var_bind_init "2b:rest"
            sx_var_bind res "2b:rest" ""
            When call sx_var_bind res "$res" "x"
            The status should be success
            The variable b should equal "x"
        End

        It '残り（rest）スロットに累積すること'
            unset out res
            sx_var_bind res "out" "a1"
            When call sx_var_bind res "$res" "a2"
            The status should be success
            The variable out should equal "a1 a2"
            The variable res should equal "out"
        End

        It 'スロットが尽きた場合に 1 を返すこと'
            unset v1 res
            sx_var_bind res "v1:" "a" # v1='a', res=''
            When call sx_var_bind res "$res" "b"
            The status should equal 1
            The variable res should equal ""
        End
    End

    Describe 'クオート動作 (SX_VAR_BIND_QUOTE)'
        It 'フラグが設定されている場合に蓄積値をクオートすること'
            unset arr out res
            # arr への単純代入はクオートされない
            sx_var_bind res "arr:out" "it's me" "$SX_VAR_BIND_QUOTE"
            # out への累積はクオートされる
            When call sx_var_bind res "$res" "don't stop" "$SX_VAR_BIND_QUOTE"
            The status should be success
            The variable arr should equal "it's me"
            The variable out should equal "'don'\''t stop'"
        End

        It 'カウント指定でもクオートが適用されること'
            unset arr rest res
            sx_var_bind res "2arr:rest" "a'b" "$SX_VAR_BIND_QUOTE"
            When call sx_var_bind res "$res" "c d" "$SX_VAR_BIND_QUOTE"
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

        It '不正なフラグに対して EX_USAGE (64) を返すこと'
            When call sx_var_bind res "v1:rest" "val" "invalid"
            The status should equal 64
        End

        It '設定エラー (EX_CONFIG: 78) を検知すること'
            check_config() {
                SX_CFG_NUM_RANGE=99
                sx_var_bind res "v1:rest" "val" 0
            }
            When call check_config
            The status should equal 78
        End
    End
End
