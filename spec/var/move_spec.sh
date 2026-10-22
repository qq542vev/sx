#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_var_move'
  Context '準備側'
    Skip if '子プロセスでは準備しない' [ "${SXTEST_DEP_FIXTURE+X}" = X ]

    launch_var_move_child() {
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
      When run launch_var_move_child
      The status should be success
      # 子では準備側の1件だけをスキップし、既存の7件を実行する。
      The stdout should include '8 examples, 0 failures, 1 skip'
      The stderr should equal ''
    End
  End

  Context '実行側'
    Skip if '親プロセスでは実行しない' [ "${SXTEST_DEP_FIXTURE+X}" != X ]

    restore_var_move_fixture() {
      Include ./spec/support/library.sh sx_var_move
      # 各Exampleで配列の初期状態を復元する。
      eval "${SXTEST_DEP_FIXTURE}"
    }
    BeforeEach restore_var_move_fixture

    It '右方向連鎖移動（v1-v2-v3）を実行すること'
      v1=AAA v2=BBB v3=CCC
      When call sx_var_move v1-v2-v3
      The status should be success
      The variable v1 should be undefined
      The variable v2 should equal "AAA"
      The variable v3 should equal "BBB"
    End

    It '左方向連鎖移動（v1=v2=v3）を実行すること'
      v1=AAA v2=BBB v3=CCC
      When call sx_var_move v1=v2=v3
      The status should be success
      The variable v3 should be undefined
      The variable v2 should equal "CCC"
      The variable v1 should equal "BBB"
    End

    It '配列を移動できること'
      When call sx_var_move myarr-newarr
      The status should be success
      The variable myarr should be undefined
      The variable myarr_len should be undefined
      The variable newarr_len should equal 2
      The variable newarr_0 should equal "a"
      The variable newarr_1 should equal "b"
    End

    It '移動先が読み取り専用の場合に EX_NOPERM を返すこと'
      v1=a
      readonly v2_ro=b
      When call sx_var_move v1-v2_ro
      The status should equal 77
      The variable v1 should equal "a"
    End

    It '移動元（削除対象）が読み取り専用の場合に EX_NOPERM を返すこと'
      readonly v1_ro=a
      v2=b
      When call sx_var_move v1_ro-v2
      The status should equal 77
    End

    It '無効な連鎖式に対して EX_USAGE を返すこと'
      When call sx_var_move "a+b"
      The status should equal 64
    End

    It '移動先と接頭辞を共有する読み取り専用変数がある場合に EX_NOPERM を返すこと'
      v1=a v2=b
      readonly v2_ro=c
      When call sx_var_move v1-v2
      The status should equal 77
      The variable v1 should equal "a"
      The variable v2 should equal "b"
    End
  End
End
