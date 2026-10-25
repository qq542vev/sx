# shellcheck shell=sh

# ビルドテストは一時コピーで実行し、作業中のソースや生成物を変更しない。
build_prepare_fixture() {
  SXTEST_BUILD_PROJECT=$PWD
  SXTEST_BUILD_DIR=$(mktemp -d "${TMPDIR:-/tmp}/sx build.XXXXXX")
  mkdir -p "$SXTEST_BUILD_DIR/m4" "$SXTEST_BUILD_DIR/tools" \
    "$SXTEST_BUILD_DIR/src/const" "$SXTEST_BUILD_DIR/src/var" "$SXTEST_BUILD_DIR/src/func"
  cp Makefile "$SXTEST_BUILD_DIR/Makefile"
  cp m4/common.m4 m4/resolve.m4 "$SXTEST_BUILD_DIR/m4/"
  cp tools/compact.awk "$SXTEST_BUILD_DIR/tools/compact.awk"
  : > "$SXTEST_BUILD_DIR/src/const.m4"
  : > "$SXTEST_BUILD_DIR/src/var.m4"
  : > "$SXTEST_BUILD_DIR/src/func.m4"
}

build_prepare_project() {
  build_prepare_fixture
  cp -R src/. "$SXTEST_BUILD_DIR/src/"
}

build_cleanup() {
  rm -rf -- "$SXTEST_BUILD_DIR"
  unset SXTEST_BUILD_DIR SXTEST_BUILD_PROJECT
}

# 外側の make の選択・出力・並列設定を持ち込まず、対応シェルを明示する。
build_make() (
  cd "$SXTEST_BUILD_DIR" || exit
  unset MAKEFLAGS MFLAGS MAKELEVEL MAKEOVERRIDES SYMBOLS OUT MOD_DIR MOD_EXT
  LC_ALL=C make -s --no-print-directory SHELL=yash "$@"
)

build_resolve() (
  cd "$SXTEST_BUILD_DIR" || exit
  LC_ALL=C m4 "-DSX_SYMBOLS=$1" -- m4/resolve.m4
)

# 使い方: build_add_unit const|var|func 名前 依存名の一覧 ソース本文
build_add_unit() {
  printf 'M_UNIT([|%s|], [|src/%s/%s.m4|])dnl\n' "$2" "$1" "$2" \
    >> "$SXTEST_BUILD_DIR/src/$1.m4"
  printf 'M_REQUIRE([|%s|])dnl\n%s\n' "$3" "$4" \
    > "$SXTEST_BUILD_DIR/src/$1/$2.m4"
}

build_symbols() {
  awk -F '[|]' '/^M_UNIT\(/ { printf "%s%s", sep, $2; sep=" " } END { print "" }' \
    "$SXTEST_BUILD_DIR/src/const.m4" "$SXTEST_BUILD_DIR/src/var.m4" \
    "$SXTEST_BUILD_DIR/src/func.m4"
}

build_function_names() {
  awk '/^(__)?sx_[a-z0-9_]+\(\) \{/ { sub(/\(\).*/, ""); print }' "$1"
}

build_inventory() (
  cd "$SXTEST_BUILD_DIR" || exit
  find . -print | LC_ALL=C sort
)

# 検証コードを新しい -efu/POSIX シェルで実行し、内部変数の漏洩も調べる。
# 使い方: build_shell_env [名前=値 ...] ::: コード [コードに渡す引数 ...]
build_shell_env() (
  cd "$SXTEST_BUILD_DIR" || exit
  unset ENV BASH_ENV SXTEST_LOAD_MOD
  unset SX_CFG_SIG_ARR SX_CFG_SKIP_CHK SX_CFG_NUM_RANGE SX_CFG_SEP
  unset SX_CFG_ARR_HOLE SX_CFG_ARR_REF
  unset SX_SYS_REV SX_SYS_NUM_WLEN SX_SYS_NUM_QM SX_SYS_NUM_ZR SX_SYS_NUM_MAX SX_SYS_NUM_MIN
  while [ "$1" != ::: ]; do
    # shellcheck disable=SC2163 # 名前=値を引数として受け取り、環境へ設定する。
    export "$1"
    shift
  done
  shift
  # shellcheck disable=SC2016 # 子シェルのコードは子シェルで展開する。
  yash -efu -o posix -c '
    . "$1/spec/spec_helper.sh"
    probe_code=$2
    shift 2
    eval "$probe_code"
    check_no_leak
  ' build-shell "$SXTEST_BUILD_PROJECT" "$@"
)

build_shell() { build_shell_env ::: "$@"; }

# 一覧は固定件数にせず、名前とパスをそれぞれ取り出す。
build_unit_names() {
  awk -F '[|]' '/^M_UNIT\(/ { print $2 }' "$@"
}

build_unit_paths() {
  awk -F '[|]' '/^M_UNIT\(/ { print $4 }' "$@"
}

# 選択生成物を新しいシェルで読み込み、指定コードの実行後に漏洩も検査する。
# 第2引数は数値域。128bit のケースでも算術演算は要求しない。
build_probe() (
  unset SX_CFG_SIG_ARR SX_CFG_SKIP_CHK SX_CFG_NUM_RANGE SX_CFG_SEP
  unset SX_CFG_ARR_HOLE SX_CFG_ARR_REF ENV BASH_ENV
  SX_CFG_NUM_RANGE=${2-64}
  export SX_CFG_NUM_RANGE
  # shellcheck disable=SC2016 # コードは子シェルで展開する。
  yash -efu -o posix -c '
    . "$2/spec/spec_helper.sh"
    . "$1"
    eval "$3"
    check_no_leak
  ' build-probe "$SXTEST_BUILD_DIR/selected.sh" "$SXTEST_BUILD_PROJECT" "$1"
)
