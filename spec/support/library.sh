# shellcheck shell=sh

# 引数は単独の提供名だけを受け取る。
case "$#" in
  1) ;;
  *)
    printf '%s\n' '単独の提供名を1つ指定してください' >&2
    exit 1
    ;;
esac
case "$1" in
  '' | [0-9]* | *[!A-Za-z0-9_]*)
    printf '%s\n' '提供名の形式が不正です' >&2
    exit 1
    ;;
esac
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
