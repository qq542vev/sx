#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_var_is_rw_all'
  Context '準備側'
    Skip if '子プロセスでは準備しない' [ "${SXTEST_DEP_FIXTURE+X}" = X ]

    launch_var_is_rw_all_child() {
      # 準備用の全体版はExample実行時だけ読み込む。
      # shellcheck source=/dev/null
      . ./sx.sh
      # 子は環境を初期化するため、入力も既定設定で準備する。
      sx_cfg_set
      sx_arr_gen myarr a b
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
      When run launch_var_is_rw_all_child
      The status should be success
      # 子では準備側の1件だけをスキップし、既存の4件を実行する。
      The stdout should include '5 examples, 0 failures, 1 skip'
      The stderr should equal ''
    End
  End

  Context '実行側'
    Skip if '親プロセスでは実行しない' [ "${SXTEST_DEP_FIXTURE+X}" != X ]

    restore_var_is_rw_all_fixture() {
      Include ./spec/support/library.sh sx_var_is_rw_all
      # 各Exampleで配列の初期状態を復元する。
      eval "${SXTEST_DEP_FIXTURE}"
    }
    BeforeEach restore_var_is_rw_all_fixture

    It 'すべての変数が書き込み可能な場合に成功を返すこと'
      v1=1 v2=2
      When call sx_var_is_rw_all v1 v2
      The status should be success
    End

    It '読み取り専用変数が含まれる場合に失敗を返すこと'
      v1=1
      readonly v2_ro=2
      When call sx_var_is_rw_all v1 v2_ro
      The status should be failure
    End

    It '配列の要素が読み取り専用の場合に失敗を返すこと'
      readonly myarr_0
      When call sx_var_is_rw_all myarr
      The status should be failure
    End

    It '無効な変数名に対して EX_USAGE を返すこと'
      When call sx_var_is_rw_all "invalid-name"
      The status should equal 64
    End
  End
End
