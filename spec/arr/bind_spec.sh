#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_arr_bind'
    Include ./sx.sh

    Describe '基本動作'
        It '通常のバインドで chain と残り bind を生成すること'
            unset br cr
            When call sx_arr_bind br cr "a:b:c" v1 v2
            The status should be success
            The variable br should equal "c"
            The variable cr should equal "v1-a v2-b"
        End

        It 'バインドより対象が少ない場合に残り bind を返すこと'
            unset br cr
            When call sx_arr_bind br cr "a:b:c" v1
            The status should be success
            The variable br should equal "b:c"
            The variable cr should equal "v1-a"
        End

        It 'カウント指定バインドで chain と残り bind を生成すること'
            unset br cr
            When call sx_arr_bind br cr "2a:rest" A B C
            The status should be success
            The variable br should equal "1/2147483647rest"
            The variable cr should equal "A-a_0 B-a_1 C-rest_0"
        End

        It 'M/N レンジ指定バインドで chain と残り bind を生成すること'
            unset br cr
            When call sx_arr_bind br cr "0/3a:rest" X Y
            The status should be success
            The variable br should equal "2/3a:rest"
            The variable cr should equal "X-a_0 Y-a_1"
        End

        It 'スキップセグメントを含むバインドを処理すること'
            unset br cr
            When call sx_arr_bind br cr "a::b" v1 v2 v3
            The status should be success
            The variable br should equal "1/2147483647b"
            The variable cr should equal "v1-a v3-b_0"
        End

        It '最終セグメント（rest）に複数累積すること'
            unset br cr
            When call sx_arr_bind br cr "a" p1 p2
            The status should be success
            The variable br should equal "2/2147483647a"
            The variable cr should equal "p1-a_0 p2-a_1"
        End

        It '末尾に空セグメントがあるバインドで drop すること'
            unset br cr
            When call sx_arr_bind br cr "3v:" w1 w2 w3
            The status should be success
            The variable br should equal ""
            The variable cr should equal "w1-v_0 w2-v_1 w3-v_2"
        End

        It '空バインドかつ対象なしで空の結果を返すこと'
            unset br cr
            When call sx_arr_bind br cr ""
            The status should be success
            The variable br should equal ""
            The variable cr should equal ""
        End
    End

    Describe 'バリデーション'
        It 'バインドが空で対象が残っている場合に 1 を返すこと'
            unset br cr
            When call sx_arr_bind br cr "" v1
            The status should equal 1
            The variable br should equal ""
            The variable cr should equal ""
        End

        It '対象が尽きる前にバインドを消費した場合に 1 を返すこと'
            unset br cr
            When call sx_arr_bind br cr "3v:" w1 w2 w3 w4
            The status should equal 1
            The variable br should equal ""
            The variable cr should equal "w1-v_0 w2-v_1 w3-v_2"
        End

        It '無効なバインド形式に対して EX_USAGE (64) を返すこと'
            unset br cr
            When call sx_arr_bind br cr "a-x:b" v1
            The status should equal 64
        End

        It '無効な変数名に対して EX_USAGE (64) を返すこと'
            unset br cr
            When call sx_arr_bind br cr "a" "x-y"
            The status should equal 64
        End

        It 'bind_res が読み取り専用の場合に EX_NOPERM (77) を返すこと'
            unset br cr
            readonly RO_RES=""
            When call sx_arr_bind RO_RES cr "a" v1
            The status should equal 77
        End

        It 'chain_res が読み取り専用の場合に EX_NOPERM (77) を返すこと'
            unset br cr
            readonly RO_CHAIN=""
            When call sx_arr_bind br RO_CHAIN "a" v1
            The status should equal 77
        End

        It '設定エラー (EX_CONFIG: 78) を検知すること'
            unset br cr
            check_config() {
                SX_CFG_NUM_RANGE=99
                sx_arr_bind br cr "a" v1
            }
            When call check_config
            The status should equal 78
        End
    End

    Context 'SX_CFG_NUM_RANGE が 64 のとき'
        It '裸セグメントの累積上限が 64bit 相当になること'
            unset br cr
            SX_CFG_NUM_RANGE=64
            When call sx_arr_bind br cr "a" p1 p2
            The status should be success
            The variable br should equal "2/9223372036854775807a"
            The variable cr should equal "p1-a_0 p2-a_1"
        End

        It '通常のバインドで chain と残り bind を生成すること'
            unset br cr
            SX_CFG_NUM_RANGE=64
            When call sx_arr_bind br cr "a:b:c" v1 v2
            The status should be success
            The variable br should equal "c"
            The variable cr should equal "v1-a v2-b"
        End
    End

    Context 'SX_CFG_SKIP_CHK が 1 のとき'
        BeforeRun 'SX_CFG_SKIP_CHK=1'

        It '通常のバインドで chain と残り bind を生成すること'
            unset br cr
            When call sx_arr_bind br cr "a:b:c" v1 v2
            The status should be success
            The variable br should equal "c"
            The variable cr should equal "v1-a v2-b"
        End

        It 'バインドが空で対象が残っている場合に 1 を返すこと'
            unset br cr
            When call sx_arr_bind br cr "" v1
            The status should equal 1
        End
    End
End