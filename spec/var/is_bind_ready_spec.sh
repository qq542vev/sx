#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_var_is_bind_ready'
    Include ./sx.sh

    readonly BIR_RO="ro"
    readonly BIR_RO_ARR="v"
    readonly BIR_RO_ARR2_LEN="0"

    Describe '受理 - bind_init 直後の状態'
        It '中間未設定・末尾設定済みの場合に成功を返すこと'
            sx_var_bind_init "bir_a:bir_b"
            When call sx_var_is_bind_ready "bir_a:bir_b"
            The status should be success
        End

        It '数値プレフィックス付きを含む場合に成功を返すこと'
            sx_var_bind_init "bir_c:2bir_d:bir_e"
            When call sx_var_is_bind_ready "bir_c:2bir_d:bir_e"
            The status should be success
        End

        It '@name が配列として生成済みの場合に成功を返すこと'
            sx_var_bind_init "bir_x:@bir_arr"
            When call sx_var_is_bind_ready "bir_x:@bir_arr"
            The status should be success
        End

        It 'N@name 中間形が配列として生成済みの場合に成功を返すこと'
            sx_var_bind_init "bir_f:2@bir_g:bir_h"
            When call sx_var_is_bind_ready "bir_f:2@bir_g:bir_h"
            The status should be success
        End

        It '複数引数がすべて準備済みの場合に成功を返すこと'
            sx_var_bind_init "bir_p:bir_q"
            sx_var_bind_init "bir_y:@bir_z"
            When call sx_var_is_bind_ready "bir_p:bir_q" "bir_y:@bir_z"
            The status should be success
        End

        It '空文字列に対して成功を返すこと'
            When call sx_var_is_bind_ready ""
            The status should be success
        End

        It 'スキップのみのバインドに対して成功を返すこと'
            When call sx_var_is_bind_ready "::"
            The status should be success
        End
    End

    Describe '拒否 - 未準備 (1)'
        It '末尾変数が未設定の場合に失敗 (1) を返すこと'
            unset bir_n1 bir_n2
            When call sx_var_is_bind_ready "bir_n1:bir_n2"
            The status should equal 1
        End

        It '数値プレフィックス付き変数が未設定の場合に失敗 (1) を返すこと'
            unset bir_n3 bir_n4
            When call sx_var_is_bind_ready "2bir_n3:bir_n4"
            The status should equal 1
        End

        It '中間変数が設定済みの場合に失敗 (1) を返すこと'
            bir_m1="x" bir_m2=""
            When call sx_var_is_bind_ready "bir_m1:bir_m2"
            The status should equal 1
        End

        It '@name の対象が未設定の場合に失敗 (1) を返すこと'
            unset bir_fresh
            When call sx_var_is_bind_ready "bir_k:@bir_fresh"
            The status should equal 1
        End

        It '@name の対象が配列でない場合に失敗 (1) を返すこと'
            bir_narr="v" bir_k2=""
            When call sx_var_is_bind_ready "bir_k2:@bir_narr"
            The status should equal 1
        End

        It '再初期化なしの再バインド状態で失敗 (1) を返すこと'
            sx_var_bind_init "bir_r1:bir_r2"
            sx_var_bind bir_res "bir_r1:bir_r2" "v1" "v2"
            When call sx_var_is_bind_ready "bir_r1:bir_r2"
            The status should equal 1
        End
    End

    Describe '拒否 - 形式不正 (EX_USAGE)'
        It '無効なバインド構文に対して EX_USAGE (64) を返すこと'
            When call sx_var_is_bind_ready "bad-name"
            The status should equal 64
        End

        It '数字名の @name に対して EX_USAGE (64) を返すこと'
            When call sx_var_is_bind_ready "@1:x"
            The status should equal 64
        End
    End

    Describe '拒否 - 権限 (EX_NOPERM)'
        It '読み取り専用変数に対して EX_NOPERM (77) を返すこと'
            When call sx_var_is_bind_ready "BIR_RO"
            The status should equal 77
        End

        It '配列本体が読み取り専用の場合に EX_NOPERM (77) を返すこと'
            When call sx_var_is_bind_ready "bir_k3:@BIR_RO_ARR"
            The status should equal 77
        End

        It '配列の _len のみが読み取り専用の場合に EX_NOPERM (77) を返すこと'
            When call sx_var_is_bind_ready "bir_k4:@BIR_RO_ARR2"
            The status should equal 77
        End
    End

    Context 'SX_CFG_SKIP_CHK が 1 のとき'
        BeforeRun 'SX_CFG_SKIP_CHK=1'

        It '未準備のバインドに対して失敗 (1) を返すこと'
            unset bir_s1 bir_s2
            When call sx_var_is_bind_ready "bir_s1:bir_s2"
            The status should equal 1
        End

        It '準備済みのバインドに対して成功を返すこと'
            sx_var_bind_init "bir_t1:bir_t2"
            When call sx_var_is_bind_ready "bir_t1:bir_t2"
            The status should be success
        End

        It '準備済みの @name に対して成功を返すこと'
            sx_var_bind_init "bir_t3:@bir_tarr"
            When call sx_var_is_bind_ready "bir_t3:@bir_tarr"
            The status should be success
        End
    End
End
