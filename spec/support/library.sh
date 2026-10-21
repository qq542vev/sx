# shellcheck shell=sh

# ShellSpec の Include から、対象の名前を第1引数に渡して読み込む。
case "${SX_TEST_MODE-module}" in
  module)
    # shellcheck source=/dev/null
    . "./build/modules/$1.sh"
    ;;
  full)
    # shellcheck source=/dev/null
    . ./sx.sh
    ;;
  *)
    printf '%s\n' 'SX_TEST_MODE は module または full を指定してください' >&2
    exit 1
    ;;
esac
