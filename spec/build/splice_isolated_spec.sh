#!/bin/sh
# shellcheck disable=SC2286,SC2288 # Parameters の値。
eval "$(shellspec - -c) exit 1"
Include ./spec/support/build.sh

Describe 'sx_arr_splice の別シェル隔離実験'
  prepare_splice() {
    build_prepare_project
    build_make 'SYMBOLS=sx_arr_gen sx_var_dump' OUT=prepare.sh
    build_make SYMBOLS=sx_arr_splice OUT=splice.sh
  }
  splice_prepare() (
    cd "$SXTEST_BUILD_PROJECT" || exit
    unset ENV BASH_ENV SX_CFG_SIG_ARR SX_CFG_SKIP_CHK SX_CFG_NUM_RANGE SX_CFG_SEP
    unset SX_CFG_ARR_UPDATE SX_CFG_ARR_HOLE SX_CFG_ARR_REF
    yash -efu -o posix ./spec/support/splice_isolated_prepare.sh \
      "$SXTEST_BUILD_DIR/prepare.sh" "$SXTEST_BUILD_DIR/fixture.sh" "$@"
  )
  splice_probe() (
    cd "$SXTEST_BUILD_PROJECT" || exit
    unset ENV BASH_ENV SX_CFG_SIG_ARR SX_CFG_SKIP_CHK SX_CFG_NUM_RANGE SX_CFG_SEP
    unset SX_CFG_ARR_UPDATE SX_CFG_ARR_HOLE SX_CFG_ARR_REF
    yash -efu -o posix ./spec/support/splice_isolated_probe.sh \
      "$SXTEST_BUILD_DIR/$1" "$SXTEST_BUILD_DIR/fixture.sh" "$2" "$3" "$4"
  )
  BeforeEach prepare_splice
  AfterEach build_cleanup

  Context '復元・置換・準備 API の非混入・漏洩'
    Parameters
      a b c
      '' "space quote'" 特殊値
    End
    It '入力データだけを別シェルへ渡し、対象モジュールだけで置換できること'
      case "$3" in 特殊値) set -- "$1" "$2" 'first
last
';; esac
      splice_prepare "$1" "$2" "$3"
      When run splice_probe splice.sh "$1" "$2" "$3"
      The status should be success
      The stdout should equal '復元・置換・隔離・漏洩検査: OK'
      The stderr should equal ''
    End
  End

  It '実行経路の依存関数を除くと127で失敗すること'
    splice_prepare a b c
    cp "$SXTEST_BUILD_DIR/splice.sh" "$SXTEST_BUILD_DIR/broken.sh"
    printf '\nunset -f __sx_arr_splice_raw\n' >> "$SXTEST_BUILD_DIR/broken.sh"
    When run splice_probe broken.sh a b c
    The status should equal 127
    The stdout should not include 'OK'
    The stderr should include '__sx_arr_splice_raw'
  End
End
