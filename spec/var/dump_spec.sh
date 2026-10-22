#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_var_dump'
  Context '準備側'
    Skip if '子プロセスでは準備しない' [ "${SXTEST_DEP_FIXTURE+X}" = X ]

    launch_var_dump_child() {
      # 準備用の全体版はExample実行時だけ読み込む。
      # shellcheck source=/dev/null
      . ./sx.sh
      # 子は環境を初期化するため、入力も既定設定で準備する。
      sx_cfg_set
      sx_arr_gen myarr item1
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
      When run launch_var_dump_child
      The status should be success
      # 子では準備側の1件だけをスキップし、既存の6件を実行する。
      The stdout should include '7 examples, 0 failures, 1 skip'
      The stderr should equal ''
    End
  End

  Context '実行側'
    Skip if '親プロセスでは実行しない' [ "${SXTEST_DEP_FIXTURE+X}" != X ]

    restore_var_dump_fixture() {
      Include ./spec/support/library.sh sx_var_dump
      # 各Exampleで配列の初期状態を復元する。
      eval "${SXTEST_DEP_FIXTURE}"
    }
    BeforeEach restore_var_dump_fixture

    It '変数の状態を代入式形式で取得すること（末尾改行あり）'
      v1="hello world"
      When call sx_var_dump res v1
      The status should be success
      The variable res should equal "v1='hello world'${SX_STR_LF}"
    End

    It '複数の変数の状態を取得すること'
      v1=a v2=b
      When call sx_var_dump res v1 v2
      The status should be success
      The variable res should equal "v1='a'${SX_STR_LF}v2='b'${SX_STR_LF}"
    End

    It '配列の状態を関連要素を含めて取得すること'
      When call sx_var_dump res myarr
      The status should be success
      # 各行が改行で終わるため、line 指定で個別に検証可能
      # myarrはBeforeEachのevalで復元する。
      # shellcheck disable=SC2154
      The line 1 of variable res should equal "myarr='${myarr}'"
      The line 2 of variable res should equal "myarr_len='1'"
      The line 3 of variable res should equal "myarr_0='item1'"
    End

    It '未設定の変数の場合に unset 命令を取得すること'
      unset undef_var
      When call sx_var_dump res undef_var
      The status should be success
      The variable res should equal "unset -v undef_var${SX_STR_LF}"
    End

    It '結果変数が読み取り専用の場合に EX_NOPERM を返すこと'
      readonly r1_dump=ro
      When call sx_var_dump r1_dump v1
      The status should equal 77
    End

    It '無効な変数名が指定された場合に EX_USAGE を返すこと'
      When call sx_var_dump res "1invalid"
      The status should equal 64
    End
  End
End
