# shellcheck shell=sh

# 第1引数は単独の提供名、またはテストのパス（後続に必要な提供名を列挙する）。
case "${SX_TEST_MODE-module}" in
  module)
    case "$1" in
      spec/*_spec.sh)
        # shellcheck source=/dev/null
        . "./build/spec-modules/${1#spec/}"
        ;;
      *)
        # shellcheck source=/dev/null
        . "./build/modules/$1.sh"
        ;;
    esac
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
