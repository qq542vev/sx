#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_var_copy'
  Context '準備側'
    Skip if '子プロセスでは準備しない' [ "${SXTEST_DEP_FIXTURE+X}" = X ]

    launch_var_copy_child() {
      # 準備用の全体版はExample実行時だけ読み込む。
      # shellcheck source=/dev/null
      . ./sx.sh
      # 子は環境を初期化するため、入力も既定設定で準備する。
      sx_cfg_set
      # 同じ配列名でも、ケースごとに異なる初期状態を保存する。
      sx_arr_gen arr1 "a" "b"
      fixture=''
      sx_var_dump fixture arr1
      sx_arr_gen arr1 "a"
      sx_arr_gen arr2 "b"
      chain_fixture=''
      sx_var_dump chain_fixture arr1 arr2
      sx_arr_gen reg_a 0 1 2
      sx_arr_gen reg_c 3
      same_dest_fixture=''
      sx_var_dump same_dest_fixture reg_a reg_c
      sx_arr_gen big_arr 0 1 2
      sx_arr_gen small_arr 9
      overwrite_fixture=''
      sx_var_dump overwrite_fixture big_arr small_arr
      sx_arr_gen src_arr a b
      array_to_scalar_fixture=''
      sx_var_dump array_to_scalar_fixture src_arr
      sx_arr_gen dst_val x
      scalar_to_array_fixture=''
      sx_var_dump scalar_to_array_fixture dst_val
      check_no_leak || return

      env -i PATH="${PATH}" HOME="${HOME}" LC_ALL="${LC_ALL:-${LANG:-C.UTF-8}}" \
        SXTEST_DEP_FIXTURE="${fixture}" \
        SXTEST_DEP_CHAIN_FIXTURE="${chain_fixture}" \
        SXTEST_DEP_SAME_DEST_FIXTURE="${same_dest_fixture}" \
        SXTEST_DEP_OVERWRITE_FIXTURE="${overwrite_fixture}" \
        SXTEST_DEP_ARRAY_TO_SCALAR_FIXTURE="${array_to_scalar_fixture}" \
        SXTEST_DEP_SCALAR_TO_ARRAY_FIXTURE="${scalar_to_array_fixture}" \
        SX_TEST_MODE="${SX_TEST_MODE-module}" \
        shellspec --shell sh --jobs 0 --no-color --no-quick \
        --warning-as-failure --fail-no-examples --format documentation \
        "${SHELLSPEC_SPECFILE}"
    }

    It '準備した配列を別のShellSpecで検証すること'
      When run launch_var_copy_child
      The status should be success
      # 子では準備側の1件だけをスキップし、既存の15件を実行する。
      The stdout should include '16 examples, 0 failures, 1 skip'
      The stderr should equal ''
    End
  End

  Context '実行側'
    Skip if '親プロセスでは実行しない' [ "${SXTEST_DEP_FIXTURE+X}" != X ]

    load_var_copy_module() {
      Include ./spec/support/library.sh sx_var_copy
    }
    BeforeEach load_var_copy_module

    Describe 'スカラー変数のコピー'
      It '単一のコピー (v1 -> v2) が成功すること'
        v1="val1"
        When call sx_var_copy v1-v2
        The status should be success
        The variable v2 should equal "val1"
      End

      It '右から左へのコピー (v1 <- v2) が成功すること'
        v2="val2"
        When call sx_var_copy v1=v2
        The status should be success
        The variable v1 should equal "val2"
      End

      It '連鎖的なコピー (v1 -> v2 -> v3) が成功すること'
        v1="new" v2="old"
        When call sx_var_copy v1-v2-v3
        The status should be success
        The variable v2 should equal "new"
        The variable v3 should equal "old"
      End

      It '未定義の変数をコピーした場合、コピー先が unset されること'
        unset -v v1 v2
        v2="target"
        When call sx_var_copy v1-v2
        The status should be success
        The variable v2 should be undefined
      End

      It '自分自身へのコピーが副作用なく成功すること'
        v1="stay"
        When call sx_var_copy v1-v1
        The status should be success
        The variable v1 should equal "stay"
      End
    End

    Describe '配列のコピー'
      It '配列構造全体がコピーされること'
        eval "${SXTEST_DEP_FIXTURE}"
        When call sx_var_copy arr1-arr2
        The status should be success
        The variable arr2_len should equal 2
        The variable arr2_0 should equal "a"
        The variable arr2_1 should equal "b"
        The variable arr2 should start with "array-sx-sig-"
      End

      It '配列の連鎖コピーが成功すること'
        eval "${SXTEST_DEP_CHAIN_FIXTURE}"
        When call sx_var_copy arr1-arr2-arr3
        The status should be success
        The variable arr2_len should equal 1
        The variable arr2_0 should equal "a"
        The variable arr3_len should equal 1
        The variable arr3_0 should equal "b"
      End

      It '同一コピー先への複数連鎖で古い要素が残らないこと'
        eval "${SXTEST_DEP_SAME_DEST_FIXTURE}"
        When call sx_var_copy reg_a-reg_b reg_c-reg_b
        The status should be success
        The variable reg_b_len should equal 1
        The variable reg_b_0 should equal "3"
        The variable reg_b_1 should be undefined
        The variable reg_b_2 should be undefined
      End

      It '要素数の少ない配列で上書きしたときに古い要素が残らないこと'
        eval "${SXTEST_DEP_OVERWRITE_FIXTURE}"
        When call sx_var_copy small_arr-big_arr
        The status should be success
        The variable big_arr_len should equal 1
        The variable big_arr_0 should equal "9"
        The variable big_arr_1 should be undefined
        The variable big_arr_2 should be undefined
      End
    End

    Describe 'エラーケース'
      It '無効な連鎖式に対して EX_USAGE を返すこと'
        When call sx_var_copy "invalid-@name"
        The status should equal 64
      End

      It 'コピー先が読み取り専用の場合に EX_NOPERM を返すこと'
        readonly ro_var="fixed"
        v1="change"
        When call sx_var_copy v1-ro_var
        The status should equal 77
      End

      It 'コピー先と接頭辞を共有する読み取り専用変数がある場合に EX_NOPERM を返すこと'
        v1=a v2=b
        readonly v2_ro=c
        When call sx_var_copy v1-v2
        The status should equal 77
        The variable v1 should equal "a"
        The variable v2 should equal "b"
      End
    End

    Describe '境界ケース'
      It '配列の内容をスカラー変数にコピーすると配列シグネチャがコピーされること'
        eval "${SXTEST_DEP_ARRAY_TO_SCALAR_FIXTURE}"
        When call sx_var_copy src_arr-dst_arr
        The variable dst_arr should start with "array-"
      End

      It 'スカラー変数の値を配列にコピーすると配列の値が変わること'
        src_val="value"
        eval "${SXTEST_DEP_SCALAR_TO_ARRAY_FIXTURE}"
        When call sx_var_copy src_val-dst_val
        The variable dst_val should equal "value"
      End

      It '連鎖コピーの途中に読み取り専用があった場合、中間状態がロールバックされること'
        a_roll=1
        readonly b_roll=0
        c_roll=3
        When call sx_var_copy a_roll-b_roll-c_roll
        The status should equal 77
        The variable a_roll should equal "1"
        The variable c_roll should equal "3"
      End
    End
  End
End
