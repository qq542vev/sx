Describe 'sx_var_is_rw_deep -efu 環境検証'
  Context '準備側'
    Skip if '子プロセスでは準備しない' [ "${SXTEST_DEP_FIXTURE+X}" = X ]

    launch_var_is_rw_deep_efu_child() {
      # 準備用の全体版はExample実行時だけ読み込む。
      # shellcheck source=/dev/null
      . ./sx.sh
      # 子は環境を初期化するため、入力も既定設定で準備する。
      sx_cfg_set
      sx_arr_gen arr a b c
      fixture=''
      sx_var_dump fixture arr
      check_no_leak || return

      env -i PATH="${PATH}" HOME="${HOME}" LC_ALL="${LC_ALL:-${LANG:-C.UTF-8}}" \
        SXTEST_DEP_FIXTURE="${fixture}" SX_TEST_MODE="${SX_TEST_MODE-module}" \
        shellspec --shell sh --jobs 0 --no-color --no-quick \
        --warning-as-failure --fail-no-examples --format documentation \
        "${SHELLSPEC_SPECFILE}"
    }

    It '準備した配列を別のShellSpecで検証すること'
      When run launch_var_is_rw_deep_efu_child
      The status should be success
      # 子では準備側の1件だけをスキップし、既存の2件を実行する。
      The stdout should include '3 examples, 0 failures, 1 skip'
      The stderr should equal ''
    End
  End

  Context '実行側'
    Skip if '親プロセスでは実行しない' [ "${SXTEST_DEP_FIXTURE+X}" != X ]

    load_var_is_rw_deep_efu_module() {
      Include ./spec/support/library.sh sx_var_is_rw_deep
    }
    BeforeEach load_var_is_rw_deep_efu_module

    It '正常動作'
      eval "${SXTEST_DEP_FIXTURE}"

      When run efu_run sx_var_is_rw_deep arr
      The status should be success
    End

    It '読み取り専用要素を検出できること'
      arr_len=1 arr_0=a
      readonly arr_0

      When run efu_run sx_var_is_rw_deep arr
      The status should be failure
    End
  End
End
