#!/bin/sh
# shellcheck disable=SC2016 # ソース・検証コードは生成物を読むシェルで展開する。
# shellcheck disable=SC2286,SC2288 # Parameters の値はコマンドではない。

eval "$(shellspec - -c) exit 1"
Include ./spec/support/build.sh

Describe '設定参照の伝播と検査の生成'
  prepare_cfg_fixture() {
    build_prepare_fixture
    build_add_unit var SX_CFG_SIG_ARR '' 'SX_CFG_SIG_ARR=sig'
    build_add_unit var SX_CFG_SKIP_CHK '' 'SX_CFG_SKIP_CHK=0'
    build_add_unit var SX_CFG_NUM_RANGE '' 'SX_CFG_NUM_RANGE=32'
    build_add_unit var SX_CFG_SEP '' 'SX_CFG_SEP=:::'
    build_add_unit var SX_CFG_ARR_HOLE '' 'SX_CFG_ARR_HOLE='
    build_add_unit var SX_CFG_ARR_REF '' 'SX_CFG_ARR_REF='
    build_add_unit func __sx_cfg_is_valid '' ''
    cp src/func/cfg/__sx_cfg_is_valid.m4 "$SXTEST_BUILD_DIR/src/func/__sx_cfg_is_valid.m4"
  }

  add_cfg_api() {
    build_add_unit func __sx_leaf 'SX_CFG_NUM_RANGE SX_CFG_ARR_HOLE' '__sx_leaf() {
  : "${SX_CFG_NUM_RANGE}"
  result="${SX_CFG_ARR_HOLE}"
}'
    build_add_unit func sx_root 'SX_CFG_SKIP_CHK __sx_leaf' 'sx_root() {
  case "${SX_CFG_SKIP_CHK-}" in 1) __sx_leaf; return;; esac
  M_CFG_CHECK([|sx_root|])
  __sx_leaf
}'
  }

  cfg_deps() (
    cd "$SXTEST_BUILD_DIR" || exit
    printf 'M_CFG_DEPS([|%s|])\n' "$1" | m4 -- m4/common.m4 -
  )

  BeforeEach prepare_cfg_fixture
  AfterEach build_cleanup

  It '多段の呼び出し先から収集し、重複を除いてメタ情報順に検査すること'
    add_cfg_api
    build_add_unit func __sx_middle '__sx_leaf SX_CFG_NUM_RANGE' '__sx_middle() { : "${SX_CFG_NUM_RANGE}"; __sx_leaf; }'
    build_add_unit func sx_top '__sx_middle __sx_leaf' 'sx_top() {
  M_CFG_CHECK([|sx_top|])
  __sx_middle
}'
    build_resolve sx_top > "$SXTEST_BUILD_DIR/selected.sh"
    When run cfg_deps sx_top
    The status should be success
    The stdout should equal '__sx_cfg_is_valid SX_CFG_NUM_RANGE SX_CFG_ARR_HOLE'
    The stderr should equal ''
    The contents of file "$SXTEST_BUILD_DIR/selected.sh" should include '__sx_cfg_is_valid "${SX_CFG_NUM_RANGE+NUM_RANGE=${SX_CFG_NUM_RANGE}}" "${SX_CFG_ARR_HOLE+ARR_HOLE=${SX_CFG_ARR_HOLE}}" || return 78'
  End

  It '循環内の全関数から設定を集め、各単位を一度だけ生成すること'
    build_add_unit func __sx_cycle_a '__sx_cycle_b SX_CFG_NUM_RANGE' '__sx_cycle_a() { : "${SX_CFG_NUM_RANGE}"; __sx_cycle_b; }'
    build_add_unit func __sx_cycle_b '__sx_cycle_a SX_CFG_ARR_HOLE' '__sx_cycle_b() { : "${SX_CFG_ARR_HOLE}"; __sx_cycle_a; }'
    build_add_unit func sx_root __sx_cycle_a 'sx_root() {
  M_CFG_CHECK([|sx_root|])
  __sx_cycle_a
}'
    build_resolve sx_root > "$SXTEST_BUILD_DIR/selected.sh"
    When run cfg_deps sx_root
    The status should be success
    The stdout should equal '__sx_cfg_is_valid SX_CFG_NUM_RANGE SX_CFG_ARR_HOLE'
    The stderr should equal ''
    The contents of file "$SXTEST_BUILD_DIR/selected.sh" should include '__sx_cycle_a()'
    The contents of file "$SXTEST_BUILD_DIR/selected.sh" should include '__sx_cycle_b()'
  End

  It '呼び出し先以外にある設定参照を混ぜず、検査関数も追加しないこと'
    build_add_unit func __sx_unrelated SX_CFG_NUM_RANGE '__sx_unrelated() { : "${SX_CFG_NUM_RANGE}"; }'
    build_add_unit func sx_root '' 'sx_root() {
  M_CFG_CHECK([|sx_root|])
  :
}'
    build_resolve sx_root > "$SXTEST_BUILD_DIR/selected.sh"
    When run cfg_deps sx_root
    The status should be success
    The stdout should equal ''
    The stderr should equal ''
    The contents of file "$SXTEST_BUILD_DIR/selected.sh" should not include '__sx_cfg_is_valid'
    The contents of file "$SXTEST_BUILD_DIR/selected.sh" should not include 'SX_CFG_NUM_RANGE'
  End

  It 'SX_SYS の初期化元を設定検査の要求として伝播しないこと'
    build_add_unit var SX_SYS_NUM_QM SX_CFG_NUM_RANGE 'SX_SYS_NUM_QM=?????????'
    build_add_unit func sx_root SX_SYS_NUM_QM 'sx_root() {
  M_CFG_CHECK([|sx_root|])
  : "${SX_SYS_NUM_QM}"
}'
    build_resolve sx_root > "$SXTEST_BUILD_DIR/selected.sh"
    When run build_probe 'SX_CFG_NUM_RANGE=99; sx_root'
    The status should be success
    The stdout should equal ''
    The stderr should equal ''
    The contents of file "$SXTEST_BUILD_DIR/selected.sh" should include 'SX_CFG_NUM_RANGE=32'
    The contents of file "$SXTEST_BUILD_DIR/selected.sh" should not include '__sx_cfg_is_valid'
  End

  It 'SKIP_CHK だけを参照する関数には検査を生成しないこと'
    build_add_unit func sx_root SX_CFG_SKIP_CHK 'sx_root() {
  M_CFG_CHECK([|sx_root|])
  : "${SX_CFG_SKIP_CHK-}"
}'
    build_resolve sx_root > "$SXTEST_BUILD_DIR/selected.sh"
    When run build_probe 'SX_CFG_SKIP_CHK=2; sx_root'
    The status should be success
    The stdout should equal ''
    The stderr should equal ''
    The contents of file "$SXTEST_BUILD_DIR/selected.sh" should not include '__sx_cfg_is_valid'
  End

  It '公開関数自身の直接参照も収集し、検査関数側の別設定は要求しないこと'
    build_add_unit func sx_root SX_CFG_ARR_HOLE 'sx_root() {
  M_CFG_CHECK([|sx_root|])
  : "${SX_CFG_ARR_HOLE}"
}'
    build_resolve sx_root > "$SXTEST_BUILD_DIR/selected.sh"
    When run build_probe 'SX_CFG_NUM_RANGE=99; sx_root'
    The status should be success
    The stdout should equal ''
    The stderr should equal ''
    The contents of file "$SXTEST_BUILD_DIR/selected.sh" should include '__sx_cfg_is_valid "${SX_CFG_ARR_HOLE+ARR_HOLE=${SX_CFG_ARR_HOLE}}" || return 78'
  End

  It '設定検査関数を明示的に呼んでも、その設定参照を伝播させないこと'
    build_add_unit func sx_root __sx_cfg_is_valid 'sx_root() {
  M_CFG_CHECK([|sx_root|])
  __sx_cfg_is_valid "NUM_RANGE=32"
}'
    When run cfg_deps sx_root
    The status should be success
    The stdout should equal ''
    The stderr should equal ''
  End

  It '設定関数を呼ぶ関数にも現在値の検査を伝播させないこと'
    build_add_unit func __sx_cfg_set SX_CFG_NUM_RANGE '__sx_cfg_set() { SX_CFG_NUM_RANGE=32; }'
    build_add_unit func sx_root __sx_cfg_set 'sx_root() {
  M_CFG_CHECK([|sx_root|])
  __sx_cfg_set
}'
    build_resolve sx_root > "$SXTEST_BUILD_DIR/selected.sh"
    When run build_probe 'SX_CFG_NUM_RANGE=99; sx_root; printf "%s" "$SX_CFG_NUM_RANGE"'
    The status should be success
    The stdout should equal 32
    The stderr should equal ''
    The contents of file "$SXTEST_BUILD_DIR/selected.sh" should not include '__sx_cfg_is_valid'
  End

  Context '設定検査の実行と値の保持'
    Parameters
      'unset SX_CFG_ARR_HOLE' '78:unchanged'
      'SX_CFG_ARR_HOLE=' '0:'
      'SX_CFG_ARR_HOLE="a * b"' '0:a * b'
      'SX_CFG_NUM_RANGE=99' '78:unchanged'
      'unset SX_CFG_NUM_RANGE' '78:unchanged'
      'SX_CFG_SEP=' '0:'
      'SX_CFG_SKIP_CHK=2' '0:'
      'SX_CFG_SKIP_CHK=1; SX_CFG_NUM_RANGE=99' '0:'
    End

    It "$1 の場合に検査結果と処理対象の値を保持すること"
      add_cfg_api
      build_resolve sx_root > "$SXTEST_BUILD_DIR/selected.sh"
      When run build_shell '
        . ./selected.sh
        result=unchanged
        eval "$1"
        if sx_root; then status=0; else status=$?; fi
        printf "%s:%s" "$status" "$result"
      ' "$1"
      The status should be success
      The stdout should equal "$2"
      The stderr should equal ''
    End
  End

  It '未知の関数名をマクロに渡したら関数の出力前に失敗すること'
    build_add_unit func sx_root '' 'sx_root() {
  M_CFG_CHECK([|sx_unknown|])
  :
}'
    When run build_resolve sx_root
    The status should be failure
    The stdout should not include 'sx_root()'
    The stderr should include '未知の関数名: sx_unknown'
  End
End

Describe '公開 API の検査と生成形式の一致'
  BeforeEach build_prepare_project
  AfterEach build_cleanup

  It 'sx_var_is_name の個別生成には設定検査関数を含めないこと'
    build_make SYMBOLS=sx_var_is_name OUT=selected.sh
    When run build_probe 'sx_var_is_name answer'
    The status should be success
    The stdout should equal ''
    The stderr should equal ''
    The contents of file "$SXTEST_BUILD_DIR/selected.sh" should not include '__sx_cfg_is_valid'
  End

  It 'sx_var_bind は下位で使う ARR_HOLE が未設定なら代入前に78を返すこと'
    build_make SYMBOLS=sx_var_bind OUT=selected.sh
    function_names=$(build_function_names "$SXTEST_BUILD_DIR/selected.sh")
    When run build_probe '
      remainder=unchanged
      tail=unchanged
      unset SX_CFG_ARR_HOLE
      if sx_var_bind remainder head:tail one two; then status=0; else status=$?; fi
      printf "%s:%s:%s:%s" "$status" "$remainder" "$tail" "${head+set}"
    '
    The status should be success
    The stdout should equal '78:unchanged:unchanged:'
    The stderr should equal ''
    The variable function_names should include '__sx_cfg_is_valid'
  End

  It '全体版・選択版・個別モジュールで同じ設定検査を生成すること'
    build_make OUT=full.sh
    build_make SYMBOLS=sx_var_bind OUT=selected.sh
    build_make module.mk
    build_make -f module.mk build/modules/sx_var_bind.sh
    awk '/^sx_var_bind\(\) \{/ { active=1 } active { print } active && /^}/ { exit }' \
      "$SXTEST_BUILD_DIR/full.sh" > "$SXTEST_BUILD_DIR/full-function.sh"
    awk '/^sx_var_bind\(\) \{/ { active=1 } active { print } active && /^}/ { exit }' \
      "$SXTEST_BUILD_DIR/selected.sh" > "$SXTEST_BUILD_DIR/selected-function.sh"
    cmp "$SXTEST_BUILD_DIR/full-function.sh" "$SXTEST_BUILD_DIR/selected-function.sh"
    When run cmp "$SXTEST_BUILD_DIR/selected.sh" "$SXTEST_BUILD_DIR/build/modules/sx_var_bind.sh"
    The status should be success
    The stdout should equal ''
    The stderr should equal ''
  End
End
