#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_var_is_rw_deep'
  Context '準備側'
    Skip if '子プロセスでは準備しない' [ "${SXTEST_DEP_FIXTURE+X}" = X ]

    launch_var_is_rw_deep_child() {
      # 準備用の全体版はExample実行時だけ読み込む。
      # shellcheck source=/dev/null
      . ./sx.sh
      # 子は環境を初期化するため、入力も既定設定で準備する。
      sx_cfg_set
      sx_arr_gen myarr a b c
      sx_arr_gen sig_arr a
      sx_arr_gen first a
      sx_arr_gen second b
      fixture=''
      sx_var_dump fixture myarr sig_arr first second
      check_no_leak || return

      env -i PATH="${PATH}" HOME="${HOME}" LC_ALL="${LC_ALL:-${LANG:-C.UTF-8}}" \
        SXTEST_DEP_FIXTURE="${fixture}" SX_TEST_MODE="${SX_TEST_MODE-module}" \
        shellspec --shell sh --jobs 0 --no-color --no-quick \
        --warning-as-failure --fail-no-examples --format documentation \
        "${SHELLSPEC_SPECFILE}"
    }

    It '準備した配列を別のShellSpecで検証すること'
      When run launch_var_is_rw_deep_child
      The status should be success
      # 子では準備側の1件だけをスキップし、既存の13件を実行する。
      The stdout should include '14 examples, 0 failures, 1 skip'
      The stderr should equal ''
    End
  End

  Context '実行側'
    Skip if '親プロセスでは実行しない' [ "${SXTEST_DEP_FIXTURE+X}" != X ]

    restore_var_is_rw_deep_fixture() {
      Include ./spec/support/library.sh sx_var_is_rw_deep
      # 各Exampleで配列の初期状態を復元する。
      eval "${SXTEST_DEP_FIXTURE}"
    }
    BeforeEach restore_var_is_rw_deep_fixture

    It '配列要素が読み取り専用でない場合は成功を返すこと'
      When call sx_var_is_rw_deep myarr
      The status should be success
    End

    It '要素が読み取り専用の場合に失敗を返すこと'
      arr_len=2 arr_0=a arr_1=b
      readonly arr_0
      When call sx_var_is_rw_deep arr
      The status should be failure
    End

    It '長さ変数が読み取り専用の場合に失敗を返すこと'
      arr_len=2 arr_0=a arr_1=b
      readonly arr_len
      When call sx_var_is_rw_deep arr
      The status should be failure
    End

    It '配列名（シグネチャ変数）が読み取り専用の場合に失敗を返すこと'
      readonly sig_arr
      When call sx_var_is_rw_deep sig_arr
      The status should be failure
    End

    It '多桁インデックスの要素が読み取り専用の場合に失敗を返すこと'
      arr_len=100
      arr_0=a
      arr_49=mid
      readonly arr_49
      When call sx_var_is_rw_deep arr
      The status should be failure
    End

    It '複数の要素が読み取り専用の場合に失敗を返すこと'
      arr_len=3 arr_0=a arr_1=b arr_2=c
      readonly arr_0 arr_2
      When call sx_var_is_rw_deep arr
      The status should be failure
    End

    It 'インデックスでないサブ変数（_foo 等）も読み取り専用として検知すること'
      arr_len=1 arr_0=a
      arr_foo=scalar
      readonly arr_foo
      When call sx_var_is_rw_deep arr
      The status should be failure
    End

    It '末尾がアンダースコアのサブ変数（_foo_ 等）は読み取り専用として誤検知しないこと'
      arr_len=1 arr_0=a
      arr_foo_=scalar
      readonly arr_foo_
      When call sx_var_is_rw_deep arr
      The status should be success
    End

    It '別変数が変数名の前方一致でも誤検知しないこと（rlen と rl）'
      rl_len=1 rl_0=a
      rlen=9
      readonly rlen
      When call sx_var_is_rw_deep rl
      The status should be success
    End

    It '値に改行を含む読み取り専用要素を検出できること'
      newline_arr_len=2
      newline_arr_0="line1
line2"
      readonly newline_arr_0
      When call sx_var_is_rw_deep newline_arr
      The status should be failure
    End

    It '空値を保持する読み取り専用要素を検出できること'
      arr_len=1
      arr_0=""
      readonly arr_0
      When call sx_var_is_rw_deep arr
      The status should be failure
    End

    It '複数の変数を指定して判定できること'
      readonly second_0
      When call sx_var_is_rw_deep first second
      The status should be failure
    End

    It '無効な変数名に対して EX_USAGE を返すこと'
      When call sx_var_is_rw_deep "invalid-name"
      The status should equal 64
    End
  End
End
