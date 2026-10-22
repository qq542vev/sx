#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_var_is_bind_ready'
    Context '準備側'
        Skip if '子プロセスでは準備しない' [ "${SXTEST_DEP_FIXTURE+X}" = X ]

        launch_var_is_bind_ready_child() {
            # 準備用の全体版はExample実行時だけ読み込む。
            # shellcheck source=/dev/null
            . ./sx.sh
            # 子は環境を初期化するため、入力も既定設定で準備する。
            sx_cfg_set
            # 初期化直後と、バインド済みの変数状態を準備する。
            sx_var_bind_init "bir_a:bir_b"
            sx_var_bind_init "bir_c:2bir_d:bir_e"
            sx_var_bind_init "bir_x:@bir_arr"
            sx_var_bind_init "bir_f:2@bir_g:bir_h"
            sx_var_bind_init "bir_p:bir_q"
            sx_var_bind_init "bir_y:@bir_z"
            sx_var_bind_init "bir_r1:bir_r2"
            sx_var_bind bir_res "bir_r1:bir_r2" "v1" "v2"
            sx_var_bind_init "bir_ro1:bir_ro2"
            sx_var_bind_init "bir_rok:@bir_roarr"
            sx_var_bind_init "bir_t1:bir_t2"
            sx_var_bind_init "bir_t3:@bir_tarr"
            fixture=''
            sx_var_dump fixture \
                bir_a bir_b \
                bir_c bir_d bir_e \
                bir_x bir_arr \
                bir_f bir_g bir_h \
                bir_p bir_q bir_y bir_z \
                bir_r1 bir_r2 bir_res \
                bir_ro1 bir_ro2 bir_rok bir_roarr \
                bir_t1 bir_t2 bir_t3 bir_tarr
            check_no_leak || return

            env -i PATH="${PATH}" HOME="${HOME}" LC_ALL="${LC_ALL:-${LANG:-C.UTF-8}}" \
                SXTEST_DEP_FIXTURE="${fixture}" SX_TEST_MODE="${SX_TEST_MODE-module}" \
                shellspec --shell sh --jobs 0 --no-color --no-quick \
                --warning-as-failure --fail-no-examples --format documentation \
                "${SHELLSPEC_SPECFILE}"
        }

        It '準備した変数を別のShellSpecで検証すること'
            When run launch_var_is_bind_ready_child
            The status should be success
            # 子では準備側の1件だけをスキップし、既存の22件を実行する。
            The stdout should include '23 examples, 0 failures, 1 skip'
            The stderr should equal ''
        End
    End

    Context '実行側'
        Skip if '親プロセスでは実行しない' [ "${SXTEST_DEP_FIXTURE+X}" != X ]

        restore_var_is_bind_ready_fixture() {
            Include ./spec/support/library.sh sx_var_is_bind_ready
            # 各Exampleで未設定・空文字列を含む変数の初期状態を復元する。
            eval "${SXTEST_DEP_FIXTURE}"
        }
        BeforeEach restore_var_is_bind_ready_fixture

        Describe '受理 - bind_init 直後の状態'
            It '中間未設定・末尾設定済みの場合に成功を返すこと'
                When call sx_var_is_bind_ready "bir_a:bir_b"
                The status should be success
            End

            It '数値プレフィックス付きを含む場合に成功を返すこと'
                When call sx_var_is_bind_ready "bir_c:2bir_d:bir_e"
                The status should be success
            End

            It '@name が配列として生成済みの場合に成功を返すこと'
                When call sx_var_is_bind_ready "bir_x:@bir_arr"
                The status should be success
            End

            It 'N@name 中間形が配列として生成済みの場合に成功を返すこと'
                When call sx_var_is_bind_ready "bir_f:2@bir_g:bir_h"
                The status should be success
            End

            It '複数引数がすべて準備済みの場合に成功を返すこと'
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

        Describe '権限分離（EX_NOPERM を返さない）'
            It '読み取り専用の素変数を含む準備済み形式に成功を返すこと'
                readonly bir_ro1 bir_ro2
                When call sx_var_is_bind_ready "bir_ro1:bir_ro2"
                The status should be success
            End

            It '読み取り専用の配列を含む準備済み形式に成功を返すこと'
                readonly bir_roarr bir_roarr_len
                When call sx_var_is_bind_ready "bir_rok:@bir_roarr"
                The status should be success
            End

            It '配列でない対象の @name に失敗 (1) を返すこと（権限ではなく状態で判定）'
                readonly BIR_P3_NARR="v"
                When call sx_var_is_bind_ready "bir_p3k:@BIR_P3_NARR"
                The status should equal 1
            End

            It '署名なしで _len のみ設定された対象の @name に失敗 (1) を返すこと'
                readonly BIR_P3_LENONLY_LEN="0"
                When call sx_var_is_bind_ready "bir_p3k2:@BIR_P3_LENONLY"
                The status should equal 1
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
                When call sx_var_is_bind_ready "bir_t1:bir_t2"
                The status should be success
            End

            It '準備済みの @name に対して成功を返すこと'
                When call sx_var_is_bind_ready "bir_t3:@bir_tarr"
                The status should be success
            End
        End
    End
End
