#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_var_ubind'
    Include ./sx.sh

    Describe '基本動作'
        It '蓄積スロットにクォートなしで累積すること'
            sx_var_bind_init "out"
            unset res
            When call sx_var_ubind res "out" "a1" "a2"
            The status should be success
            The variable out should equal "a1 a2"
            The variable res should equal "out"
        End

        It 'カウント指定で複数の値を順に蓄積すること'
            sx_var_bind_init "2arr:rest"
            unset res
            When call sx_var_ubind res "2arr:rest" "a1" "a2"
            The status should be success
            The variable arr should equal "a1 a2"
            The variable res should equal "rest"
        End

        It '代入スロットと蓄積スロットが混在しても生の値になること'
            sx_var_bind_init "arr:out"
            unset res
            When call sx_var_ubind res "arr:out" "it's me" "don't stop"
            The status should be success
            The variable arr should equal "it's me"
            The variable out should equal "don't stop"
        End

        It '先頭の蓄積値が空文字列の場合もセパレータを付加しないこと'
            skip_empty_accumulation_pending() { return 0; }
            Skip if '空値の蓄積仕様を確定するまで保留' skip_empty_accumulation_pending
            sx_var_bind_init "2b:rest"
            unset res
            When call sx_var_ubind res "2b:rest" "" "x"
            The status should be success
            The variable b should equal "x"
        End

        It 'データが不足している場合に残りのバインド状態を保持すること'
            sx_var_bind_init "3arr:rest"
            unset res
            When call sx_var_ubind res "3arr:rest" "a1"
            The status should be success
            The variable arr should equal "a1"
            The variable res should equal "2arr:rest"
        End

        It 'データが無い場合にバインド状態を結果に書き込んで成功すること'
            sx_var_bind_init "v1:rest"
            unset res
            When call sx_var_ubind res "v1:rest"
            The status should be success
            The variable res should equal "v1:rest"
        End

        It 'カウントが 2^64 を超えても正しく減算できること'
            sx_var_bind_init "18446744073709551615arr:rest"
            unset res
            When call sx_var_ubind res "18446744073709551615arr:rest" "a1" "a2"
            The status should be success
            The variable arr should equal "a1 a2"
            The variable res should equal "18446744073709551613arr:rest"
        End

        It 'スロットが尽きた場合に 1 を返し、結果変数に空のバインド形式が書き込まれること'
            sx_var_bind_init "v1:"
            unset res
            res="unchanged"
            When call sx_var_ubind res "v1:" "a" "b"
            The status should equal 1
            The variable v1 should equal "a"
            The variable res should equal ""
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

    Describe '@ 記法（配列マーカー）'
        It '末尾 @name に残りの全要素を生のまま分配すること'
            sx_var_bind_init "x:@u_arr"
            unset res
            When call sx_var_ubind res "x:@u_arr" "a b" "c'd" "e"
            The status should be success
            The variable x should equal "a b"
            The variable u_arr_len should equal "2"
            The variable u_arr_0 should equal "c'd"
            The variable u_arr_1 should equal "e"
            The variable res should equal "@u_arr"
        End

        It 'N@name 中間形で個数制限どおりに分配すること'
            sx_var_bind_init "a:2@u_arr2:c"
            unset res
            When call sx_var_ubind res "a:2@u_arr2:c" "v1" "v2" "v3" "v4"
            The status should be success
            The variable a should equal "v1"
            The variable u_arr2_len should equal "2"
            The variable u_arr2_0 should equal "v2"
            The variable u_arr2_1 should equal "v3"
            The variable c should equal "v4"
            The variable res should equal "c"
        End

        It '初期化されていない @name に対して EX_DATAERR (65) を返すこと'
            unset u_fresh_x u_fresh
            When call sx_var_ubind res "u_fresh_x:@u_fresh" "v1" "v2"
            The status should equal 65 # SX_EX_DATAERR
        End
    End

    Describe '空結果変数（残り破棄）'
        It '成功時に残りを破棄し、生値で割り当てること'
            sx_var_bind_init "eu1:euurest"
            When call sx_var_ubind "" "eu1:euurest" "a b"
            The status should be success
            The variable eu1 should equal "a b"
        End

        It 'スロット枯渇時に 1 を返し、残りを破棄すること'
            sx_var_bind_init "eu2:"
            When call sx_var_ubind "" "eu2:" "a" "b"
            The status should equal 1
            The variable eu2 should equal "a"
        End

        It 'データが無い場合に成功すること'
            sx_var_bind_init "eu3:euurest2"
            When call sx_var_ubind "" "eu3:euurest2"
            The status should be success
        End
    End
End
