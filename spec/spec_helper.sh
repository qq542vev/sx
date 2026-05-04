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
