#!/bin/sh
# shellcheck disable=SC2016 # 検証コードは生成物を読み込む子シェルで展開する。
# shellcheck disable=SC2286,SC2288 # Parameters の値はコマンドではない。

eval "$(shellspec - -c) exit 1"

Include ./spec/support/build.sh

Describe 'make による全体版・部分版の生成'
  BeforeEach build_prepare_project
  AfterEach build_cleanup

  Context '既定ターゲット・all・bundle の選択生成'
    Parameters
      ''
      all
      bundle
    End

    It "${1:-既定ターゲット} で指定した機能だけを生成すること"
      case "$1" in '') set --;; esac
      build_make SYMBOLS=sx_uri_enc OUT=selected.sh "$@"
      function_names=$(build_function_names "$SXTEST_BUILD_DIR/selected.sh")
      When run build_probe 'sx_uri_enc answer "a b"; printf "%s" "$answer"'
      The status should be success
      The stdout should equal 'a%20b'
      The stderr should equal ''
      The variable function_names should not include 'sx_uri_is_pct'
    End
  End

  It '代表生成物が shebang を持ち、POSIX モードで構文検査に通ること'
    build_make SYMBOLS=sx_uri_enc OUT=selected.sh
    When run yash -o posix -n "$SXTEST_BUILD_DIR/selected.sh"
    The status should be success
    The stdout should equal ''
    The stderr should equal ''
    The line 1 of contents of file "$SXTEST_BUILD_DIR/selected.sh" should equal '#!/bin/sh'
  End

  It '複数の機能を指定して両方を実行できること'
    build_make 'SYMBOLS=sx_uri_enc sx_uri_is_pct' OUT=selected.sh
    When run build_probe 'sx_uri_enc answer "a b"; sx_uri_is_pct "$answer"; printf "%s" "$answer"'
    The status should be success
    The stdout should equal 'a%20b'
    The stderr should equal ''
  End

  It '選択を変えて再生成すると以前の機能が残らないこと'
    build_make 'SYMBOLS=sx_uri_enc sx_uri_is_pct' OUT=selected.sh
    build_make SYMBOLS=sx_uri_enc OUT=selected.sh
    function_names=$(build_function_names "$SXTEST_BUILD_DIR/selected.sh")
    When run build_probe 'sx_uri_enc answer "a b"; printf "%s" "$answer"'
    The status should be success
    The stdout should equal 'a%20b'
    The stderr should equal ''
    The variable function_names should not include 'sx_uri_is_pct'
  End

  It '同じ名前を重複指定しても生成結果が変わらないこと'
    build_make SYMBOLS=sx_uri_enc OUT=single.sh
    build_make 'SYMBOLS=sx_uri_enc sx_uri_enc' OUT=duplicate.sh
    When run cmp "$SXTEST_BUILD_DIR/single.sh" "$SXTEST_BUILD_DIR/duplicate.sh"
    The status should be success
    The stdout should equal ''
    The stderr should equal ''
  End

  Context '数値の最大値だけを選択した生成物'
    Parameters
      32
      64
      128
    End

    It "数値域 $1 で必要な定数を参照でき、最小値を含まないこと"
      build_make SYMBOLS=SX_SYS_NUM_MAX OUT=selected.sh
      When run build_probe '
        case $SX_CFG_NUM_RANGE in
          32) expected=$SX_NUM_I32_MAX;;
          64) expected=$SX_NUM_I64_MAX;;
          128) expected=$SX_NUM_I128_MAX;;
        esac
        [ "$SX_SYS_NUM_MAX" = "$expected" ]
      ' "$1"
      The status should be success
      The stdout should equal ''
      The stderr should equal ''
      The contents of file "$SXTEST_BUILD_DIR/selected.sh" should not include 'SX_SYS_NUM_MIN='
      The contents of file "$SXTEST_BUILD_DIR/selected.sh" should not include 'SX_NUM_I32_MIN='
      The contents of file "$SXTEST_BUILD_DIR/selected.sh" should not include 'SX_NUM_I64_MIN='
      The contents of file "$SXTEST_BUILD_DIR/selected.sh" should not include 'SX_NUM_I128_MIN='
    End
  End

  Context '選択引数の指定方法と全体生成の一致'
    Parameters
      未指定
      空文字列
      全単位を明示
    End

    It "$1 で同じ全体版を生成すること"
      build_make OUT=expected.sh all
      case "$1" in
        未指定) set --;;
        空文字列) set -- 'SYMBOLS=';;
        全単位を明示) set -- "SYMBOLS=$(build_symbols)";;
      esac
      build_make "$@" > "$SXTEST_BUILD_DIR/actual.sh"
      When run cmp "$SXTEST_BUILD_DIR/expected.sh" "$SXTEST_BUILD_DIR/actual.sh"
      The status should be success
      The stdout should equal ''
      The stderr should equal ''
    End
  End

  Context 'OUT が未指定・空文字列の場合'
    Parameters
      '' 未指定
      '' 空文字列
      all 未指定
      all 空文字列
      bundle 未指定
      bundle 空文字列
    End

    It "${1:-既定ターゲット} で OUT が $2 なら標準出力へ生成すること"
      build_make SYMBOLS=sx_uri_enc OUT=expected.sh
      case "$2" in
        未指定) set -- "$1";;
        空文字列) set -- "$1" 'OUT=';;
      esac
      case "$1" in '') shift;; esac
      build_make SYMBOLS=sx_uri_enc "$@" > "$SXTEST_BUILD_DIR/actual.sh"
      When run cmp "$SXTEST_BUILD_DIR/expected.sh" "$SXTEST_BUILD_DIR/actual.sh"
      The status should be success
      The stdout should equal ''
      The stderr should equal ''
      The path "$SXTEST_BUILD_DIR/sx.sh" should not exist
    End
  End

  It 'OUT の親ディレクトリを作成し、空白を含むパスへ保存できること'
    When run build_make SYMBOLS=sx_uri_enc 'OUT=nested path/selected.sh'
    The status should be success
    The stdout should equal ''
    The stderr should equal ''
    The path "$SXTEST_BUILD_DIR/nested path/selected.sh" should be file
    The line 1 of contents of file "$SXTEST_BUILD_DIR/nested path/selected.sh" should equal '#!/bin/sh'
  End

  Context '生成に失敗した場合'
    Parameters
      unknown_name '未定義の名前'
      bad-name '形式が不正'
    End

    It "$1 を拒否し、既存の出力を保持すること"
      printf '%s\n' '既存の内容' > "$SXTEST_BUILD_DIR/selected.sh"
      When run build_make "SYMBOLS=$1" OUT=selected.sh
      The status should be failure
      The stdout should equal ''
      The stderr should include "$2"
      The contents of file "$SXTEST_BUILD_DIR/selected.sh" should equal '既存の内容'
    End
  End

  It '生成に失敗しても作業ディレクトリに不要なファイルを残さないこと'
    printf '%s\n' '既存の内容' > "$SXTEST_BUILD_DIR/selected.sh"
    build_inventory > "$SHELLSPEC_WORKDIR/bundle-before"
    When run build_make SYMBOLS=unknown_name OUT=selected.sh
    The status should be failure
    The stdout should equal ''
    The stderr should include '未定義の名前'
    build_inventory > "$SHELLSPEC_WORKDIR/bundle-after"
    The contents of file "$SHELLSPEC_WORKDIR/bundle-after" should equal "$(cat "$SHELLSPEC_WORKDIR/bundle-before")"
  End
End

Describe 'make test の生成対象とテスト呼び出し'
  BeforeEach build_prepare_fixture
  AfterEach build_cleanup

  run_test_target() (
    PATH="$SXTEST_BUILD_DIR/bin:$PATH"
    SXTEST_LOAD_MOD=sx.sh
    export PATH SXTEST_LOAD_MOD
    build_make SYMBOLS=sx_selected OUT=unused.sh 'TEST_FLAGS=--format documentation' test
  )

  It '部分選択を解除して全体版・個別モジュールを生成し、指定オプションで1回テストすること'
    build_add_unit func sx_selected '' 'sx_selected() { :; }'
    build_add_unit func sx_other '' 'sx_other() { :; }'
    mkdir "$SXTEST_BUILD_DIR/bin"
    # 実際の ShellSpec を再帰実行せず、呼び出し時の環境と引数だけを記録する。
    cat > "$SXTEST_BUILD_DIR/bin/shellspec" <<'SH'
#!/bin/sh
set -efu
printf '%s\n' "${SXTEST_LOAD_MOD-unset}" "$@" >> shellspec.calls
SH
    chmod 755 "$SXTEST_BUILD_DIR/bin/shellspec"
    When run run_test_target
    The status should be success
    The stdout should equal ''
    The stderr should equal ''
    The contents of file "$SXTEST_BUILD_DIR/sx.sh" should include 'sx_other() {'
    The path "$SXTEST_BUILD_DIR/build/modules/sx_selected.sh" should be file
    The path "$SXTEST_BUILD_DIR/build/modules/sx_other.sh" should be file
    The path "$SXTEST_BUILD_DIR/unused.sh" should not exist
    The contents of file "$SXTEST_BUILD_DIR/shellspec.calls" should equal 'unset
--format
documentation'
  End
End
