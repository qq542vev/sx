#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_var_set'
  Context '準備側'
    Skip if '子プロセスでは準備しない' [ "${SXTEST_DEP_FIXTURE+X}" = X ]

    launch_var_set_child() {
      # 準備用の全体版はExample実行時だけ読み込む。
      # shellcheck source=/dev/null
      . ./sx.sh
      # 子は環境を初期化するため、入力も既定設定で準備する。
      sx_cfg_set
      sx_arr_gen myarr x y
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
      When run launch_var_set_child
      The status should be success
      # 子では準備側の1件だけをスキップし、既存の9件を実行する。
      The stdout should include '10 examples, 0 failures, 1 skip'
      The stderr should equal ''
    End
  End

  Context '実行側'
    Skip if '親プロセスでは実行しない' [ "${SXTEST_DEP_FIXTURE+X}" != X ]

    restore_var_set_fixture() {
      Include ./spec/support/library.sh sx_var_set
      # 各Exampleで配列の初期状態を復元する。
      eval "${SXTEST_DEP_FIXTURE}"
    }
    BeforeEach restore_var_set_fixture

    It '複数の変数を設定すること'
      When call sx_var_set v1=a v2=b
      The status should be success
      The variable v1 should equal "a"
      The variable v2 should equal "b"
    End

    It '値が指定されない場合、変数を未設定にすること'
      v1=a v2=b
      When call sx_var_set v1 v2
      The status should be success
      The variable v1 should be undefined
      The variable v2 should be undefined
    End

    It 'いずれかの変数が読み取り専用の場合に EX_NOPERM を返すこと'
      readonly r1_set=ro
      When call sx_var_set v3=c r1_set=err v4=d
      The status should equal 77
      The variable v3 should be undefined
      The variable v4 should be undefined
    End

    It '配列名を指定した場合、配列全体（要素含む）を削除すること'
      When call sx_var_set myarr
      The status should be success
      The variable myarr should be undefined
      The variable myarr_len should be undefined
      The variable myarr_0 should be undefined
    End

    It '値に特殊文字（スペース）を含む変数を設定できること'
      When call sx_var_set "v=hello world"
      The variable v should equal "hello world"
    End

    It '値を空文字列に設定できること'
      v=old
      When call sx_var_set v=
      The variable v should equal ""
    End

    It '読み取り専用変数が混在している場合、全変数が未設定のままであること'
      readonly r1_set_ro=ro
      When call sx_var_set a_ro=1 r1_set_ro=err b_ro=2
      The status should equal 77
      The variable a_ro should be undefined
      The variable b_ro should be undefined
    End

    It '複数の変数を一度に設定し、すべて正しく設定されていること'
      When call sx_var_set a_batch=1 b_batch=2 c_batch=3
      The variable a_batch should equal 1
      The variable b_batch should equal 2
      The variable c_batch should equal 3
    End

    It '既存の変数の値を上書きできること'
      v_over=old
      When call sx_var_set v_over=new
      The variable v_over should equal "new"
    End
  End
End
