Describe 'sx_var_bind -efu 環境検証'
  Context '準備側'
    Skip if '子プロセスでは準備しない' [ "${SXTEST_DEP_FIXTURE+X}" = X ]

    launch_var_bind_efu_child() {
      # 準備用の全体版はExample実行時だけ読み込む。
      # shellcheck source=/dev/null
      . ./sx.sh
      # 子は環境を初期化するため、入力も既定設定で準備する。
      sx_cfg_set
      # 同名の変数を使うケースも、初期状態を個別に保存する。
      sx_var_bind_init "v1:v2:rest"
      fixture=''
      sx_var_dump fixture v1 v2 rest
      sx_var_bind_init "v1:"
      exhaust_fixture=''
      sx_var_dump exhaust_fixture v1
      sx_var_bind_init "x:@e_arr"
      arr_fixture=''
      sx_var_dump arr_fixture x e_arr
      sx_var_bind_init "e1:e2:erest"
      empty_fixture=''
      sx_var_dump empty_fixture e1 e2 erest
      sx_var_bind_init "e3:"
      empty_exhaust_fixture=''
      sx_var_dump empty_exhaust_fixture e3
      check_no_leak || return

      env -i PATH="${PATH}" HOME="${HOME}" LC_ALL="${LC_ALL:-${LANG:-C.UTF-8}}" \
        SXTEST_DEP_FIXTURE="${fixture}" \
        SXTEST_DEP_EXHAUST_FIXTURE="${exhaust_fixture}" \
        SXTEST_DEP_ARR_FIXTURE="${arr_fixture}" \
        SXTEST_DEP_EMPTY_FIXTURE="${empty_fixture}" \
        SXTEST_DEP_EMPTY_EXHAUST_FIXTURE="${empty_exhaust_fixture}" \
        SX_TEST_MODE="${SX_TEST_MODE-module}" \
        shellspec --shell sh --jobs 0 --no-color --no-quick \
        --warning-as-failure --fail-no-examples --format documentation \
        "${SHELLSPEC_SPECFILE}"
    }

    It '準備した変数を別のShellSpecで検証すること'
      When run launch_var_bind_efu_child
      The status should be success
      # 子では準備側の1件だけをスキップし、既存の5件を実行する。
      The stdout should include '6 examples, 0 failures, 1 skip'
      The stderr should equal ''
    End
  End

  Context '実行側'
    Skip if '親プロセスでは実行しない' [ "${SXTEST_DEP_FIXTURE+X}" != X ]

    load_var_bind_efu_module() {
      Include ./spec/support/library.sh sx_var_bind
    }
    BeforeEach load_var_bind_efu_module

    It '正常動作'
      efu_bind_ok() {
        eval "${SXTEST_DEP_FIXTURE}"
        sx_var_bind res "v1:v2:rest" "val1" "val2" "val3"
      }

      When run efu_run efu_bind_ok
      The status should be success
    End

    It 'バインド先の枯渇で 1 を返すこと'
      efu_bind_exhaust() {
        eval "${SXTEST_DEP_EXHAUST_FIXTURE}"
        sx_var_bind res "v1:" "a" "b"
      }

      When run efu_run efu_bind_exhaust
      The status should equal 1
    End

    It '@name への分配が正常動作すること'
      efu_bind_arr() {
        eval "${SXTEST_DEP_ARR_FIXTURE}"
        sx_var_bind res "x:@e_arr" "v1" "v2" "v3"
      }

      When run efu_run efu_bind_arr
      The status should be success
    End

    It '空結果変数で残りを破棄できること'
      efu_bind_empty() {
        eval "${SXTEST_DEP_EMPTY_FIXTURE}"
        sx_var_bind "" "e1:e2:erest" "a"
      }

      When run efu_run efu_bind_empty
      The status should be success
    End

    It '空結果変数で枯渇時に 1 を返すこと'
      efu_bind_empty_exhaust() {
        eval "${SXTEST_DEP_EMPTY_EXHAUST_FIXTURE}"
        sx_var_bind "" "e3:" "a" "b"
      }

      When run efu_run efu_bind_empty_exhaust
      The status should equal 1
    End
  End
End
