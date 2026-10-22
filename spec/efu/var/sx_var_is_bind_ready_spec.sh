Describe 'sx_var_is_bind_ready -efu 環境検証'
  Context '準備側'
    Skip if '子プロセスでは準備しない' [ "${SXTEST_DEP_FIXTURE+X}" = X ]

    launch_var_is_bind_ready_efu_child() {
      # 準備用の全体版はExample実行時だけ読み込む。
      # shellcheck source=/dev/null
      . ./sx.sh
      # 子は環境を初期化するため、入力も既定設定で準備する。
      sx_cfg_set
      sx_var_bind_init "bir_e1:bir_e2" "bir_re1:bir_re2"
      fixture=''
      sx_var_dump fixture bir_e1 bir_e2 bir_re1 bir_re2
      check_no_leak || return

      env -i PATH="${PATH}" HOME="${HOME}" LC_ALL="${LC_ALL:-${LANG:-C.UTF-8}}" \
        SXTEST_DEP_FIXTURE="${fixture}" SX_TEST_MODE="${SX_TEST_MODE-module}" \
        shellspec --shell sh --jobs 0 --no-color --no-quick \
        --warning-as-failure --fail-no-examples --format documentation \
        "${SHELLSPEC_SPECFILE}"
    }

    It '準備した変数を別のShellSpecで検証すること'
      When run launch_var_is_bind_ready_efu_child
      The status should be success
      # 子では準備側の1件だけをスキップし、既存の4件を実行する。
      The stdout should include '5 examples, 0 failures, 1 skip'
      The stderr should equal ''
    End
  End

  Context '実行側'
    Skip if '親プロセスでは実行しない' [ "${SXTEST_DEP_FIXTURE+X}" != X ]

    restore_var_is_bind_ready_efu_fixture() {
      Include ./spec/support/library.sh sx_var_is_bind_ready
      # 各Exampleで未設定・空文字列を含む変数の初期状態を復元する。
      eval "${SXTEST_DEP_FIXTURE}"
    }
    BeforeEach restore_var_is_bind_ready_efu_fixture

    It '準備済みの場合の正常動作'
      bir_efu_ok_case() {
        sx_var_is_bind_ready "bir_e1:bir_e2"
      }

      When run efu_run bir_efu_ok_case
      The status should be success
    End

    It '未準備の場合の失敗動作'
      bir_efu_ng_case() {
        unset bir_e3 bir_e4
        sx_var_is_bind_ready "bir_e3:bir_e4"
      }

      When run efu_run bir_efu_ng_case
      The status should equal 1
    End

    It '不正形式の場合の失敗動作'
      bir_efu_bad_case() {
        sx_var_is_bind_ready "bad-name"
      }

      When run efu_run bir_efu_bad_case
      The status should equal 64
    End

    It '読み取り専用変数を含む準備済み形式に成功を返すこと'
      bir_efu_ro_case() {
        readonly bir_re1 bir_re2
        sx_var_is_bind_ready "bir_re1:bir_re2"
      }

      When run efu_run bir_efu_ro_case
      The status should be success
    End
  End
End
