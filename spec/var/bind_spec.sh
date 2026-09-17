#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_var_bind'
    Include ./sx.sh

    Describe '基本動作'
        It '単純な代入を実行し、状態を更新すること'
            sx_var_bind_init "v1:v2:rest"
            unset res
            When call sx_var_bind res "v1:v2:rest" "val1"
            The status should be success
            The variable v1 should equal "val1"
            The variable res should equal "v2:rest"
        End

        It '複数の値を一度に割り当てること'
            sx_var_bind_init "v1:v2:rest"
            unset res
            When call sx_var_bind res "v1:v2:rest" "a" "b" "c"
            The status should be success
            The variable v1 should equal "a"
            The variable v2 should equal "b"
            The variable rest should equal "'c'"
            The variable res should equal "rest"
        End

        It 'スキップスロットを正しく処理すること'
            sx_var_bind_init ":v2:rest"
            unset res
            When call sx_var_bind res ":v2:rest" "discarded" "val2"
            The status should be success
            The variable v2 should equal "val2"
            The variable res should equal "rest"
        End

        It 'カウント指定代入を処理すること'
            sx_var_bind_init "2arr:rest"
            unset res
            When call sx_var_bind res "2arr:rest" "a1" "a2"
            The status should be success
            The variable arr should equal "'a1' 'a2'"
            The variable res should equal "rest"
        End

        It 'データが不足している場合に残りのバインド状態を保持すること'
            sx_var_bind_init "3arr:rest"
            unset res
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
            sx_var_bind_init "out"
            unset res
            When call sx_var_bind res "out" "a1" "a2"
            The status should be success
            The variable out should equal "'a1' 'a2'"
            The variable res should equal "out"
        End

        It 'スロットが尽きた場合に 1 を返し、結果変数に空のバインド形式が書き込まれること'
            sx_var_bind_init "v1:"
            unset res
            res="unchanged"
            When call sx_var_bind res "v1:" "a" "b"
            The status should equal 1
            The variable v1 should equal "a"
            The variable res should equal ""
        End

        It 'データが無い場合にバインド状態を結果に書き込んで成功すること'
            sx_var_bind_init "v1:rest"
            unset res
            When call sx_var_bind res "v1:rest"
            The status should be success
            The variable res should equal "v1:rest"
        End
    End

    Describe 'クォート動作'
        It '代入スロットは生の値、蓄積スロットはクォートされること'
            sx_var_bind_init "arr:out"
            unset res
            When call sx_var_bind res "arr:out" "it's me" "don't stop"
            The status should be success
            The variable arr should equal "it's me"
            The variable out should equal "'don'\''t stop'"
        End

        It 'カウント指定でもクォートが適用されること'
            sx_var_bind_init "2arr:rest"
            unset res
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

    Describe '@ 記法（配列マーカー）'
        It '末尾 @name に残りの全要素を分配すること'
            sx_var_bind_init "x:@b_arr"
            unset res
            When call sx_var_bind res "x:@b_arr" "v1" "v2" "v3"
            The status should be success
            The variable x should equal "v1"
            The variable b_arr_len should equal "2"
            The variable b_arr_0 should equal "v2"
            The variable b_arr_1 should equal "v3"
            The variable res should equal "@b_arr"
        End

        It 'N@name 中間形で個数制限どおりに分配すること'
            sx_var_bind_init "a:2@b_arr2:c"
            unset res
            When call sx_var_bind res "a:2@b_arr2:c" "v1" "v2" "v3" "v4"
            The status should be success
            The variable a should equal "v1"
            The variable b_arr2_len should equal "2"
            The variable b_arr2_0 should equal "v2"
            The variable b_arr2_1 should equal "v3"
            The variable c should equal "'v4'"
            The variable res should equal "c"
        End

        It '空白やクォートを含む値を生のまま格納すること'
            sx_var_bind_init "x:@b_arr3"
            unset res
            When call sx_var_bind res "x:@b_arr3" "a b" "c'd" "e f"
            The status should be success
            The variable x should equal "a b"
            The variable b_arr3_len should equal "2"
            The variable b_arr3_0 should equal "c'd"
            The variable b_arr3_1 should equal "e f"
        End

        It '単独 @name に全要素を分配すること'
            sx_var_bind_init "@b_arr5"
            unset res
            When call sx_var_bind res "@b_arr5" "v1" "v2"
            The status should be success
            The variable b_arr5_len should equal "2"
            The variable b_arr5_0 should equal "v1"
            The variable b_arr5_1 should equal "v2"
            The variable res should equal "@b_arr5"
        End

        It 'データが無い場合にバインド形式を残して成功すること'
            sx_var_bind_init "x:@b_arr4"
            unset res
            When call sx_var_bind res "x:@b_arr4"
            The status should be success
            The variable b_arr4_len should equal "0"
            The variable res should equal "x:@b_arr4"
        End

        It '初期化されていない @name に対して EX_DATAERR (65) を返すこと'
            unset b_fresh_x b_fresh
            When call sx_var_bind res "b_fresh_x:@b_fresh" "v1" "v2"
            The status should equal 65 # SX_EX_DATAERR
        End

        It '読み取り専用の配列に対して EX_NOPERM (77) を返すこと'
            sx_arr_gen ro_barr "x"
            readonly ro_barr ro_barr_len ro_barr_0
            When call sx_var_bind res "bq:@ro_barr" "v"
            The status should equal 77 # SX_EX_NOPERM
        End
    End

    Describe '空結果変数（残り破棄）'
        It '成功時に残りを破棄し、割当ては実行すること'
            sx_var_bind_init "eb1:eb2:eberest"
            When call sx_var_bind "" "eb1:eb2:eberest" "a"
            The status should be success
            The variable eb1 should equal "a"
        End

        It 'スロット枯渇時に 1 を返し、残りを破棄すること'
            sx_var_bind_init "eb3:"
            When call sx_var_bind "" "eb3:" "a" "b"
            The status should equal 1
            The variable eb3 should equal "a"
        End

        It 'データが無い場合に成功すること'
            sx_var_bind_init "eb4:eberest2"
            When call sx_var_bind "" "eb4:eberest2"
            The status should be success
        End
    End
End
