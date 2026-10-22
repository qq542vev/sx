#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_var_is_arr'
  Context '準備側'
    Skip if '子プロセスでは準備しない' [ "${SXTEST_DEP_FIXTURE+X}" = X ]

    launch_is_arr_child() {
      # 準備用の全体版はExample実行時だけ読み込む。
      # shellcheck source=/dev/null
      . ./sx.sh
      # 子は環境を初期化するため、入力も既定設定で準備する。
      sx_cfg_set
      sx_arr_gen myarr a b
      fixture=''
      sx_var_dump fixture myarr
      check_no_leak || return

      # 配列のデータだけを渡し、実行モードは親と揃える。
      env -i PATH="${PATH}" HOME="${HOME}" LC_ALL="${LC_ALL:-${LANG:-C.UTF-8}}" \
        SXTEST_DEP_FIXTURE="${fixture}" SX_TEST_MODE="${SX_TEST_MODE-module}" \
        shellspec --shell sh --jobs 0 --no-color --no-quick \
        --warning-as-failure --fail-no-examples --format documentation \
        "${SHELLSPEC_SPECFILE}"
    }

    It '準備した配列を別のShellSpecで検証すること'
      When run launch_is_arr_child
      The status should be success
      # 子では準備側の1件だけをスキップし、判定2件を実行する。
      The stdout should include '3 examples, 0 failures, 1 skip'
      The stderr should equal ''
    End
  End

  Context '判定側'
    Skip if '親プロセスでは判定しない' [ "${SXTEST_DEP_FIXTURE+X}" != X ]

    restore_is_arr_fixture() {
      Include ./spec/support/library.sh sx_var_is_arr
      eval "${SXTEST_DEP_FIXTURE}"
    }
    BeforeEach restore_is_arr_fixture

    It 'sx配列に対して成功を返すこと'
      When call sx_var_is_arr myarr
      The status should be success
    End

    It '通常の変数に対して失敗を返すこと'
      regular_var="val"
      When call sx_var_is_arr regular_var
      The status should be failure
    End
  End
End
