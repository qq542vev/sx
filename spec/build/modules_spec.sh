#!/bin/sh
# shellcheck disable=SC2016 # 子シェルや m4 で評価する検証コード。

eval "$(shellspec - -c) exit 1"

Include ./spec/support/build.sh

Describe '実際の単位の個別生成'
  BeforeEach build_prepare_project
  AfterEach build_cleanup

  It 'URI エンコードの個別モジュールに必要な依存だけが含まれ、実行できること'
    build_make module.mk
    build_make -f module.mk OUT=unused.sh build/modules/sx_uri_enc.sh
    names=$(build_function_names "$SXTEST_BUILD_DIR/build/modules/sx_uri_enc.sh")
    When run build_shell '. ./build/modules/sx_uri_enc.sh; sx_uri_enc result "a b"; printf "%s" "$result"'
    The status should be success
    The stdout should equal 'a%20b'
    The stderr should equal ''
    The variable names should include 'sx_uri_enc'
    The variable names should include '__sx_uri_enc'
    The variable names should not include 'sx_uri_is_pct'
    The path "$SXTEST_BUILD_DIR/unused.sh" should not exist
    The line 1 of contents of file "$SXTEST_BUILD_DIR/build/modules/sx_uri_enc.sh" should equal '#!/bin/sh'
  End

  It '複数の対象を別ファイルに生成し、依存が小さい判定モジュールを実行できること'
    build_make module.mk
    build_make -f module.mk build/modules/sx_uri_enc.sh build/modules/sx_uri_is_pct.sh
    names=$(build_function_names "$SXTEST_BUILD_DIR/build/modules/sx_uri_is_pct.sh")
    When run build_shell '. ./build/modules/sx_uri_is_pct.sh; sx_uri_is_pct "a%20b"'
    The status should be success
    The stdout should equal ''
    The stderr should equal ''
    The variable names should equal 'sx_uri_is_pct
__sx_uri_is_pct'
    The contents of file "$SXTEST_BUILD_DIR/build/modules/sx_uri_is_pct.sh" should not include 'SX_SYS_REV'
    The contents of file "$SXTEST_BUILD_DIR/build/modules/sx_uri_is_pct.sh" should not include 'SX_CFG_NUM_RANGE'
    The path "$SXTEST_BUILD_DIR/build/modules/sx_uri_enc.sh" should be file
  End

  Context 'ライブラリの権限は umask を反映し、実行権限を付けない'
    Parameters
      022 '-rw-r--r--'
      077 '-rw-------'
    End
    module_mode() (
      umask "$1"
      build_make module.mk
      build_make -f module.mk build/modules/sx_uri_enc.sh
      # shellcheck disable=SC2012 # 固定した単一ファイルの権限欄だけを取り出す。
      LC_ALL=C ls -l "$SXTEST_BUILD_DIR/build/modules/sx_uri_enc.sh" | cut -c 1-10
    )
    It "umask $1 で $2 になること"
      When run module_mode "$1"
      The status should be success
      The stdout should equal "$2"
      The stderr should equal ''
    End
  End

  It '生成の失敗時には既存のモジュールを保持し、一時ファイルを残さないこと'
    build_make module.mk
    build_make -f module.mk build/modules/sx_uri_enc.sh
    cp "$SXTEST_BUILD_DIR/build/modules/sx_uri_enc.sh" "$SXTEST_BUILD_DIR/saved.sh"
    printf '%s\n' 'm4exit(1)' > "$SXTEST_BUILD_DIR/m4/resolve.m4"
    build_inventory > "$SHELLSPEC_WORKDIR/module-before"
    When run build_make -f module.mk build/modules/sx_uri_enc.sh
    The status should be failure
    The stderr should include 'Error'
    The contents of file "$SXTEST_BUILD_DIR/build/modules/sx_uri_enc.sh" should equal "$(cat "$SXTEST_BUILD_DIR/saved.sh")"
    build_inventory > "$SHELLSPEC_WORKDIR/module-after"
    The contents of file "$SHELLSPEC_WORKDIR/module-after" should equal "$(cat "$SHELLSPEC_WORKDIR/module-before")"
  End
End

Describe 'module.mk の一覧更新と再生成'
  prepare_modules() {
    build_prepare_fixture
    build_add_unit const SX_STR_SAMPLE '' 'readonly SX_STR_SAMPLE=sample'
    build_add_unit var SX_SYS_SAMPLE SX_STR_SAMPLE 'SX_SYS_SAMPLE=$SX_STR_SAMPLE'
    build_add_unit func __sx_sample SX_SYS_SAMPLE '__sx_sample() { result=$SX_SYS_SAMPLE; }'
    build_add_unit func sx_sample __sx_sample 'sx_sample() { __sx_sample; }'
  }
  BeforeEach prepare_modules
  AfterEach build_cleanup

  It '部分選択と OUT によらず全単位を並列生成すること'
    When run build_make -j4 SYMBOLS=unknown_name OUT=unused.sh module
    The status should be success
    The stdout should equal ''
    The stderr should equal ''
    The path "$SXTEST_BUILD_DIR/build/modules/SX_STR_SAMPLE.sh" should be file
    The path "$SXTEST_BUILD_DIR/build/modules/SX_SYS_SAMPLE.sh" should be file
    The path "$SXTEST_BUILD_DIR/build/modules/__sx_sample.sh" should be file
    The path "$SXTEST_BUILD_DIR/build/modules/sx_sample.sh" should be file
    The path "$SXTEST_BUILD_DIR/unused.sh" should not exist
    The path "$SXTEST_BUILD_DIR/build/modules/func.sh" should not exist
    The path "$SXTEST_BUILD_DIR/spec" should not exist
  End

  It '指定した個別対象に依存先が含まれること'
    build_make module.mk
    build_make -f module.mk build/modules/sx_sample.sh
    When run build_shell '. ./build/modules/sx_sample.sh; sx_sample; printf "%s" "$result"'
    The status should be success
    The stdout should equal 'sample'
    The stderr should equal ''
    The path "$SXTEST_BUILD_DIR/build/modules/SX_STR_SAMPLE.sh" should not exist
  End

  It '直接 module.mk の既定ターゲットを実行すると全対象を生成すること'
    build_make module.mk
    When run build_make -f module.mk
    The status should be success
    The stdout should equal ''
    The stderr should equal ''
    The path "$SXTEST_BUILD_DIR/build/modules/SX_STR_SAMPLE.sh" should be file
    The path "$SXTEST_BUILD_DIR/build/modules/SX_SYS_SAMPLE.sh" should be file
    The path "$SXTEST_BUILD_DIR/build/modules/__sx_sample.sh" should be file
    The path "$SXTEST_BUILD_DIR/build/modules/sx_sample.sh" should be file
  End

  Context 'ソースが未変更でも毎回生成する'
    Parameters
      module
      直接実行
    End
    It "$1 で既存の内容を再生成すること"
      build_make module
      printf '%s\n' '古い内容' > "$SXTEST_BUILD_DIR/build/modules/sx_sample.sh"
      case "$1" in
        module) build_make module;;
        *) build_make -f module.mk;;
      esac
      When run build_shell '. ./build/modules/sx_sample.sh; sx_sample; printf "%s" "$result"'
      The status should be success
      The stdout should equal 'sample'
      The stderr should equal ''
    End
  End

  It '指定した対象だけを再生成し、他の対象を書き換えないこと'
    build_make module
    printf '%s\n' '古い内容' > "$SXTEST_BUILD_DIR/build/modules/sx_sample.sh"
    printf '%s\n' '他の内容' > "$SXTEST_BUILD_DIR/build/modules/SX_STR_SAMPLE.sh"
    build_make -f module.mk build/modules/sx_sample.sh
    When run build_shell '. ./build/modules/sx_sample.sh; sx_sample; printf "%s" "$result"'
    The status should be success
    The stdout should equal 'sample'
    The stderr should equal ''
    The contents of file "$SXTEST_BUILD_DIR/build/modules/SX_STR_SAMPLE.sh" should equal '他の内容'
  End

  Context '共通ソースや一覧の更新後も全対象を生成する'
    Parameters
      Makefile
      m4/common.m4
      m4/resolve.m4
      tools/compact.awk
      src/const.m4
      src/var.m4
      src/func.m4
    End
    It "$1 の更新後に全対象を再生成すること"
      build_make module
      touch "$SXTEST_BUILD_DIR/$1"
      for generated in SX_STR_SAMPLE SX_SYS_SAMPLE __sx_sample sx_sample; do
        printf '%s\n' '古い内容' > "$SXTEST_BUILD_DIR/build/modules/$generated.sh"
      done
      build_make -f module.mk
      When run build_shell '. ./build/modules/sx_sample.sh; sx_sample; printf "%s" "$result"'
      The status should be success
      The stdout should equal 'sample'
      The stderr should equal ''
      The contents of file "$SXTEST_BUILD_DIR/build/modules/SX_STR_SAMPLE.sh" should include 'readonly SX_STR_SAMPLE=sample'
      The contents of file "$SXTEST_BUILD_DIR/build/modules/SX_SYS_SAMPLE.sh" should include 'SX_SYS_SAMPLE=$SX_STR_SAMPLE'
      The contents of file "$SXTEST_BUILD_DIR/build/modules/__sx_sample.sh" should include '__sx_sample()'
    End
  End

  Context '未知の個別ターゲット'
    Parameters
      unknown_name
      1invalid
    End
    It "$1 の生成ルールがないこと"
      build_make module.mk
      When run build_make -f module.mk "build/modules/$1.sh"
      The status should be failure
      The stderr should include 'No rule to make target'
      The path "$SXTEST_BUILD_DIR/build/modules/$1.sh" should not exist
    End
  End

  It '追加した単位は一覧更新後に生成できること'
    build_make module.mk
    build_add_unit func sx_added '' 'sx_added() { :; }'
    cp "$SXTEST_BUILD_DIR/module.mk" "$SXTEST_BUILD_DIR/saved.mk"
    When run build_make -f module.mk build/modules/sx_added.sh
    The status should be failure
    The stderr should include 'No rule to make target'
    The contents of file "$SXTEST_BUILD_DIR/module.mk" should equal "$(cat "$SXTEST_BUILD_DIR/saved.mk")"
    build_make module
    The path "$SXTEST_BUILD_DIR/build/modules/sx_added.sh" should be file
  End

  It '削除した単位は一覧更新後に生成対象から外れること'
    build_make module.mk
    : > "$SXTEST_BUILD_DIR/src/func.m4"
    rm "$SXTEST_BUILD_DIR/src/func/sx_sample.m4" "$SXTEST_BUILD_DIR/src/func/__sx_sample.m4"
    When run build_make -f module.mk
    The status should be failure
    The stderr should include '未定義の名前'
    build_make module.mk
    The contents of file "$SXTEST_BUILD_DIR/module.mk" should not include 'sx_sample'
    build_make -f module.mk
  End

  It '出力ディレクトリと拡張子を指定できること'
    When run build_make MOD_DIR=custom MOD_EXT=.lib module
    The status should be success
    The stdout should equal ''
    The stderr should equal ''
    The path "$SXTEST_BUILD_DIR/custom/sx_sample.lib" should be file
    The path "$SXTEST_BUILD_DIR/build/modules/sx_sample.sh" should not exist
  End

  It 'clean は生成物を削除し、ソースを保持すること'
    build_make module
    When run build_make clean
    The status should be success
    The stdout should equal ''
    The stderr should equal ''
    The path "$SXTEST_BUILD_DIR/module.mk" should not exist
    The path "$SXTEST_BUILD_DIR/build/modules/sx_sample.sh" should not exist
    The path "$SXTEST_BUILD_DIR/src/func/sx_sample.m4" should be file
  End

  Context '廃止したターゲット'
    Parameters
      modules
      test-modules
    End
    It "$1 を受理しないこと"
      When run build_make "$1"
      The status should be failure
      The stderr should include 'No rule to make target'
    End
  End
End
