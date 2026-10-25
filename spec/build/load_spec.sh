#!/bin/sh
# shellcheck disable=SC2016 # 子シェルで実行する検証コード。
# shellcheck disable=SC2286,SC2288 # Parameters の値。
eval "$(shellspec - -c) exit 1"
Include ./spec/support/build.sh

Describe 'sxtest_load による個別モジュールの読み込み'
  prepare_load() {
    build_prepare_fixture
    mkdir -p "$SXTEST_BUILD_DIR/build/modules"
    cat > "$SXTEST_BUILD_DIR/build/modules/sx_first.sh" <<'SH'
loaded="${loaded-}first "
loaded_fn() { printf '%s' available; }
SH
    printf '%s\n' 'loaded="${loaded-}second "' > "$SXTEST_BUILD_DIR/build/modules/sx_second.sh"
    printf '%s\n' 'return 23' > "$SXTEST_BUILD_DIR/build/modules/sx_fail.sh"
  }
  BeforeEach prepare_load
  AfterEach build_cleanup

  It '引数順に読み込み、関数定義と呼び出し元の位置引数を保持すること'
    When run build_shell '
      set -- parent "a b"
      sxtest_load ./build/modules/sx_second.sh ./build/modules/sx_first.sh
      printf "%s|%s|%s|%s" "$loaded" "$#" "$1" "$2"
      loaded_fn
    '
    The status should be success
    The stdout should equal 'second first |2|parent|a bavailable'
    The stderr should equal ''
  End

  It '環境変数で引数を置き換え、連続する空白を区切りとして扱うこと'
    When run build_shell_env 'SXTEST_LOAD_MOD=  ./build/modules/sx_second.sh   ./build/modules/sx_first.sh  ' ::: 'sxtest_load invalid:name; printf "%s" "$loaded"'
    The status should be success
    The stdout should equal 'second first '
    The stderr should equal ''
  End

  It '引数も環境指定もなければ何も読み込まないこと'
    When run build_shell 'sxtest_load; printf "%s" "${loaded-unset}"'
    The status should be success
    The stdout should equal 'unset'
    The stderr should equal ''
  End

  Context '空の環境指定'
    Parameters
      ''
      '   '
    End
    It "環境指定が '$1' なら引数を無視して何も読み込まないこと"
      When run build_shell_env "SXTEST_LOAD_MOD=$1" ::: 'sxtest_load invalid:name; printf "%s" "${loaded-unset}"'
      The status should be success
      The stdout should equal 'unset'
      The stderr should equal ''
    End
  End

  Context '環境指定を分割した後の呼び出し元の状態'
    Parameters
      'IFS=:; set +f'
      'IFS=; set -f'
      'unset IFS; set +f'
    End
    It "$1 の IFS とオプションを保持すること"
      When run build_shell_env 'SXTEST_LOAD_MOD=./build/modules/sx_first.sh ./build/modules/sx_second.sh' ::: '
        eval "$1"
        before_ifs="${IFS+x}:${IFS-}"
        before_flags=$-
        sxtest_load
        [ "${IFS+x}:${IFS-}" = "$before_ifs" ]
        [ "$-" = "$before_flags" ]
        printf "%s" "$loaded"
      ' "$1"
      The status should be success
      The stdout should equal 'first second '
      The stderr should equal ''
    End
  End

  It '読み込み先にも復元済みの IFS とオプションが見えること'
    printf '%s\n' 'observed_ifs=$IFS' 'observed_flags=$-' > "$SXTEST_BUILD_DIR/build/modules/sx_state.sh"
    When run build_shell_env 'SXTEST_LOAD_MOD=./build/modules/sx_state.sh' ::: '
      IFS=:; set +f
      before_flags=$-
      sxtest_load
      [ "$observed_flags" = "$before_flags" ]
      printf "%s" "$observed_ifs"
    '
    The status should be success
    The stdout should equal ':'
    The stderr should equal ''
  End

  It '重複指定したモジュールも順番どおり再度読み込むこと'
    When run build_shell 'sxtest_load ./build/modules/sx_first.sh ./build/modules/sx_first.sh; printf "%s" "$loaded"'
    The status should be success
    The stdout should equal 'first first '
    The stderr should equal ''
  End

  It '空のパス引数を64で拒否すること'
    When run build_shell 'sxtest_load ""'
    The status should equal 64
    The stdout should equal ''
    The stderr should include 'パスが空'
  End

  Context '引数のパスは文字列として扱う'
    Parameters
      'sx_*.sh'
      'x;exit 29'
      '$(exit 29)'
      'build/modules'
    End
    It "$1 を展開・実行せず、読込不可として扱うこと"
      printf '%s\n' 'loaded=expanded' > "$SXTEST_BUILD_DIR/sx_first.sh"
      When run build_shell 'set +f; sxtest_load "$1"' "$1"
      The status should equal 1
      The stdout should equal ''
      The stderr should include "ファイルを読み込めません: $1"
    End
  End

  Context '環境指定のパスも文字列として扱う'
    Parameters
      'sx_*.sh' 'sx_*.sh'
      'x;exit 29' 'x;exit'
      '$(exit 29)' '$(exit'
      'build/modules' 'build/modules'
    End
    It "$1 を空白分割以外には展開・実行しないこと"
      printf '%s\n' 'loaded=expanded' > "$SXTEST_BUILD_DIR/sx_first.sh"
      When run build_shell_env "SXTEST_LOAD_MOD=$1" ::: 'set +f; sxtest_load'
      The status should equal 1
      The stdout should equal ''
      The stderr should include "ファイルを読み込めません: $2"
    End
  End

  It '絶対パス・相対パス・親パスと、引用符や空白を含む名前を読み込めること'
    printf '%s\n' 'loaded="${loaded-}path "' > "$SXTEST_BUILD_DIR/space quote' *.sh"
    When run build_shell '
      sxtest_load "$PWD/$1"
      sxtest_load "$1"
      cd build
      sxtest_load "../$1"
      printf "%s" "$loaded"
    ' "space quote' *.sh"
    The status should be success
    The stdout should equal 'path path path '
    The stderr should equal ''
  End

  It '環境指定の sx.sh は PATH を検索せず作業ディレクトリから読み込むこと'
    printf '%s\n' 'loaded=full' > "$SXTEST_BUILD_DIR/sx.sh"
    mkdir "$SXTEST_BUILD_DIR/shadow"
    printf '%s\n' 'loaded=wrong' > "$SXTEST_BUILD_DIR/shadow/sx.sh"
    When run build_shell_env SXTEST_LOAD_MOD=sx.sh ::: '
      PATH="$PWD/shadow:$PATH"
      sxtest_load ./build/modules/sx_first.sh
      printf "%s" "$loaded"
    '
    The status should be success
    The stdout should equal 'full'
    The stderr should equal ''
  End

  It '読込不可でも呼び出し元を終了せず、状態1を返すこと'
    When run build_shell '
      if sxtest_load ./build/modules/sx_missing.sh; then exit 99; else status=$?; fi
      printf "%s" "$status"
    '
    The status should be success
    The stdout should equal '1'
    The stderr should include 'sx_missing'
  End

  It '読み込み先の失敗を返し、後続のモジュールを読み込まないこと'
    When run build_shell '
      if sxtest_load ./build/modules/sx_fail.sh ./build/modules/sx_first.sh; then exit 99; else status=$?; fi
      printf "%s:%s" "$status" "${loaded-unset}"
    '
    The status should be success
    The stdout should equal '23:unset'
    The stderr should equal ''
  End

  It '実物の個別モジュールを読み込んで実行できること'
    cp -R "$SXTEST_BUILD_PROJECT/src/." "$SXTEST_BUILD_DIR/src/"
    build_make SYMBOLS=sx_uri_enc OUT=build/modules/sx_uri_enc.sh
    When run build_shell 'sxtest_load ./build/modules/sx_uri_enc.sh; sx_uri_enc result "a b"; printf "%s" "$result"'
    The status should be success
    The stdout should equal 'a%20b'
    The stderr should equal ''
  End
End
