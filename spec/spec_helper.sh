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
  # 全ての Example (It ブロック) の後に自動実行
  after_each 'check_no_leak'

  # Available functions: import, before_each, after_each, before_all, after_all
  : import 'support/custom_matcher'
}

# 内部変数の漏洩をチェックする関数
# __で始まる変数がsetの結果に残っているかを確認します。
check_no_leak() {
  # setの結果から "__変数名=値" の形式の行を抽出
  # 内部関数定義が "name ()" や "name=()" となるシェルがあるため、
  # 確実に変数と思われるもの（=を含み、()を含まない）に絞り込みます。
  __check_leak_vars_=$(set | grep "^__[a-zA-Z0-9_]*=" | grep -v "(" || true)

  if [ -n "$__check_leak_vars_" ]; then
    # 漏洩している変数名を表示（デバッグ用）
    echo "Leaked internal variables:" >&2
    echo "$__check_leak_vars_" >&2
    unset __check_leak_vars_
    return 1
  fi
  unset __check_leak_vars_
}
