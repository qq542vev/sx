#!/bin/sh
# shellcheck disable=SC2016 # CMD内の変数は準備用シェルで展開する。

eval "$(shellspec - -c) exit 1"

Describe 'sx_arr_push'
  # shellcheck disable=SC2329
  setup_myarr_fixture() {
    sxtest_run myarr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" myarr a
  }
  Include ./spec/support/run.sh
  Include ./spec/support/library.sh sx_arr_push
  BeforeEach setup_myarr_fixture

  It '要素を配列の末尾に追加すること'
    When call sx_arr_push myarr b c
    The status should be success
    The variable myarr_len should equal 3
    The variable myarr_0 should equal "a"
    The variable myarr_1 should equal "b"
    The variable myarr_2 should equal "c"
  End

  It '値が指定されない場合は何もしないこと'
    When call sx_arr_push myarr
    The status should be success
    The variable myarr_len should equal 1
  End

  It '対象が sx 配列でない場合に EX_DATAERR を返すこと'
    not_an_arr="val"
    When call sx_arr_push not_an_arr x
    The status should equal 65
  End

  It '読み取り専用の配列に対して EX_NOPERM を返すこと'
    sxtest_run ro_arr_push SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" ro_arr_push
    readonly ro_arr_push
    When call sx_arr_push ro_arr_push x
    The status should equal 77
  End

  It '配列の長さ変数が読み取り専用の場合に EX_NOPERM を返すこと'
    sxtest_run len_ro_arr SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" len_ro_arr a
    readonly len_ro_arr_len
    When call sx_arr_push len_ro_arr b
    The status should equal 77
  End

  It '空文字列の要素をプッシュできること'
    sxtest_run myarr_empty SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" myarr_empty a
    When call sx_arr_push myarr_empty ""
    The variable myarr_empty_len should equal 2
    The variable myarr_empty_1 should equal ""
  End

  It '特殊文字を含む要素をプッシュできること'
    sxtest_run myarr_spec SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" myarr_spec
    When call sx_arr_push myarr_spec "it's" 'say "hello"'
    The variable myarr_spec_0 should equal "it's"
    The variable myarr_spec_1 should equal 'say "hello"'
  End

  It '5個の要素を連続プッシュできること'
    sxtest_run myarr_mul SX_SYS_REV -- 'SX_SYS_REV=$1; shift; sx_arr_gen "$@"' "${SX_SYS_REV-0}" myarr_mul
    sx_arr_push myarr_mul a
    sx_arr_push myarr_mul b
    sx_arr_push myarr_mul c
    sx_arr_push myarr_mul d
    sx_arr_push myarr_mul e
    When call sx_arr_push myarr_mul "last"
    The variable myarr_mul_len should equal 6
    The variable myarr_mul_5 should equal "last"
  End

  It 'ARR_REF 設定時は参照をコピーしてプッシュすること'
    src="hello"
    setup_command='
      SX_SYS_REV=$1
      sx_arr_gen myarr_push_ref
      sx_cfg_set "ARR_REF=@"
    '
    sxtest_run myarr_push_ref SX_CFG_ARR_REF SX_SYS_REV -- "$setup_command" "${SX_SYS_REV-0}"
    When call sx_arr_push myarr_push_ref "@src"
    The status should be success
    The variable myarr_push_ref_0 should equal "hello"
    sxtest_run SX_CFG_ARR_REF -- 'sx_cfg_set "$@"' "ARR_REF"
    sxtest_run myarr_push_ref myarr_push_ref_len myarr_push_ref_0 src -- \
      'sx_var_unset "$@"' myarr_push_ref myarr_push_ref_len myarr_push_ref_0 src
  End

  It '参照値とリテラルを指定順に末尾へ追加すること'
    src="reference"
    setup_command='
      SX_SYS_REV=$1
      sx_arr_gen myarr_push_mixed head
      sx_cfg_set "ARR_REF=@"
    '
    sxtest_run myarr_push_mixed SX_CFG_ARR_REF SX_SYS_REV -- "$setup_command" "${SX_SYS_REV-0}"
    When call sx_arr_push myarr_push_mixed "@src" literal
    The status should be success
    The variable myarr_push_mixed_len should equal 3
    The variable myarr_push_mixed_0 should equal "head"
    The variable myarr_push_mixed_1 should equal "reference"
    The variable myarr_push_mixed_2 should equal "literal"
    sxtest_run SX_CFG_ARR_REF -- 'sx_cfg_set "$@"' "ARR_REF"
    sxtest_run myarr_push_mixed myarr_push_mixed_len myarr_push_mixed_0 myarr_push_mixed_1 myarr_push_mixed_2 src -- \
      'sx_var_unset "$@"' myarr_push_mixed myarr_push_mixed_len myarr_push_mixed_0 myarr_push_mixed_1 myarr_push_mixed_2 src
  End
End
