# shellcheck shell=sh

# Defining variables and functions here will affect all specfiles.
# Change shell options inside a function may cause different behavior,
# so it is better to set them here.
# set -eu

# This callback function will be invoked only once before loading specfiles.
spec_helper_precheck() {
  # Available functions: info, warn, error, abort, setenv, unsetenv
  # Available variables: VERSION, SHELL_TYPE, SHELL_VERSION
  : minimum_version "0.28.1"
}

# This callback function will be invoked after a specfile has been loaded.
spec_helper_loaded() {
  :
}

# This callback function will be invoked after core modules has been loaded.
spec_helper_configure() {
  # 全ての Example を -efu (errexit, nounset, noglob) 下で実行する。
  # ターゲット環境 (yash -efu -o posix) での動作を検証するため。
  # 注: shellspec_set は Set ヘルパーの内部関数。shellspec のバージョン更新時は要確認。
  shellspec_set 'errexit:on' 'nounset:on' 'noglob:on'

  # 全ての Example (It ブロック) の後に自動実行
  after_each 'check_no_leak'

  # Available functions: import, before_each, after_each, before_all, after_all
  : import 'support/custom_matcher'
}

### sxtest_load - 指定した個別モジュールを現在のシェルへ読み込む
## 使い方: sxtest_load [mod ...]
## 説明:
##   mod は build/modules/<mod>.sh の提供名を指定する。
##   SXTEST_LOAD_MOD が設定済みなら、引数をその値の空白区切りの一覧で置き換える。
##   空の一覧では何もせず成功する。重複する指定も順番どおり読み込む。
##   呼び出し元の IFS とパス名展開の設定は、読み込み前に復元する。
## 終了ステータス: 0 成功、64 提供名不正、1 読込不可、その他は読み込み先の終了状態。
sxtest_load() {
  case "${SXTEST_LOAD_MOD+X}" in X)
    # 位置パラメータに呼び出し元の状態を保存し、空白1文字だけで分割する。
    set -- "${IFS+x}" "${IFS-}" "$-"
    IFS=' '
    set -f
    # shellcheck disable=SC2086 # 空白での分割を行い、パス名展開は無効にしている。
    set -- "$1" "$2" "$3" $SXTEST_LOAD_MOD
    case "$1" in x) IFS=$2;; *) unset IFS;; esac
    case "$3" in *f*) ;; *) set +f;; esac
    shift 3
  esac

  while case "$#" in 0) ! :;; esac; do
    case "$1" in '' | [0-9]* | *[!A-Za-z0-9_]*)
      printf '%s\n' '提供名の形式が不正です' >&2
      return 64
    esac
    if [ ! -r "./build/modules/$1.sh" ]; then
      printf '%s\n' "モジュールを読み込めません: $1" >&2
      return 1
    fi
    # shellcheck source=/dev/null
    . "./build/modules/$1.sh" || return
    shift
  done
  return 0
}

# 算術域を設定値に依存せず検査する。致命的な算術エラーはサブシェルに閉じ込め、
# ラップするシェルでも最大値・最小値の結果が一致しなければ64bit未満と判定する。
arith_lt64() {
  (
    case "$((0x7fffffffffffffff)):$((-0x7fffffffffffffff - 1))" in
      9223372036854775807:-9223372036854775808) exit 0;;
      *) exit 1;;
    esac
  ) 2>&- && return 1
  return 0
}

# 新設の境界ケースを32bit算術環境だけで実行するための判定。
arith_is32() {
  (
    case "$((0x7fffffff)):$((-0x7fffffff - 1))" in
      2147483647:-2147483648) exit 0;;
      *) exit 1;;
    esac
  ) 2>&- || return 1
  arith_lt64
}

# ShellSpec の Skip if に渡す否定条件。
arith_not32() { ! arith_is32; }

# 内部変数の漏洩をチェックする関数
# __で始まる変数がsetの結果に残っているかを確認します。
check_no_leak() {
  __check_leak_vars_=""
  # set の出力を 1 行ずつ読み込み、内部変数（__で始まる）を探します。
  # 外部コマンド (grep) を使わず、シェルの組み込み機能のみで判定します。
  # set の出力を直接パイプで渡すと、多くのシェルでループがサブシェル内になり
  # __check_leak_vars_ の変更が反映されないため、ヒアドキュメントを使用します。
  while IFS= read -r __line_; do
    case "${__line_}" in
      __check_leak_vars_=* | __line_=*) ;;
      __[a-zA-Z0-9_]*=*)
        # 関数定義（"name ()" など）を除外するため、 "(" を含まないことを確認
        case "${__line_}" in
          *"("* ) ;;
          *) __check_leak_vars_="${__check_leak_vars_}${__line_}
" ;;
        esac
        ;;
    esac
  done <<EOF
$(set)
EOF

  if [ -n "${__check_leak_vars_}" ]; then
    # 漏洩している変数名を表示（デバッグ用）
    echo "Leaked internal variables:" >&2
    echo "${__check_leak_vars_}" >&2
    unset __check_leak_vars_ __line_
    return 1
  fi
  unset __check_leak_vars_ __line_
}

# -e 検証用ヘルパー: サブシェル内で -efu を有効にして sx 関数を呼び出す。
# When run はサブシェル実行のため、-e 下での関数動作を status で検証できる。
efu_run() {
  # shellcheck disable=SC3040
  set -efu -o posix
  "$@"
}

# efu spec 用の共通コールバック定義
efu_cb_set3() { __sx_var_set "${1}=${3}"; }
efu_cb_sum() { __sx_var_set "${1}=$((${2} + ${3}))"; }
efu_cb_set2() { __sx_var_set "${1}=${2}"; }
efu_cb_true() { return 0; }
