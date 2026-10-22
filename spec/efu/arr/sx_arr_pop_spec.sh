Describe 'sx_arr_pop -efu 環境検証'
  Context '準備側'
    Skip if '子プロセスでは準備しない' [ "${SXTEST_DEP_FIXTURE+X}" = X ]

    launch_arr_pop_efu_child() {
      # 準備用の全体版はExample実行時だけ読み込む。
      # shellcheck source=/dev/null
      . ./sx.sh
      # 子は環境を初期化するため、入力も既定設定で準備する。
      sx_cfg_set
      sx_arr_gen myarr a b c
      fixture=''
      sx_var_dump fixture myarr
      check_no_leak || return

      env -i PATH="${PATH}" HOME="${HOME}" LC_ALL="${LC_ALL:-${LANG:-C.UTF-8}}" \
        SXTEST_DEP_FIXTURE="${fixture}" SX_TEST_MODE="${SX_TEST_MODE-module}" \
        shellspec --shell sh --jobs 0 --no-color --no-quick \
        --warning-as-failure --fail-no-examples --format documentation \
        "${SHELLSPEC_SPECFILE}"
    }

    It '準備した配列を別のShellSpecで検証すること'
      When run launch_arr_pop_efu_child
      The status should be success
      # 子では準備側の1件だけをスキップし、正常・要素不足の2件を実行する。
      The stdout should include '3 examples, 0 failures, 1 skip'
      The stderr should equal ''
    End
  End

  Context '実行側'
    Skip if '親プロセスでは実行しない' [ "${SXTEST_DEP_FIXTURE+X}" != X ]

    restore_arr_pop_efu_fixture() {
      Include ./spec/support/library.sh sx_arr_pop
      # 各Exampleで配列の初期状態を復元する。
      eval "${SXTEST_DEP_FIXTURE}"
    }
    BeforeEach restore_arr_pop_efu_fixture

    It '正常動作'
      When run efu_run sx_arr_pop x: myarr
      The status should be success
    End

    It '要素不足で 1 を返すこと'
      When run efu_run sx_arr_pop x:y:z:w: myarr
      The status should equal 1
    End
  End
End
