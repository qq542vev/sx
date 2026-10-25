#!/bin/sh
# 新しいシェルで対象モジュールとデータだけを読み込み、復元と置換を検査する。
# shellcheck disable=SC2154
# shellcheck source=/dev/null
. "$1"
# spec_helper はライブラリを読み込まない。既存の漏洩検査を利用する。
. ./spec/spec_helper.sh
for helper in sx_arr_gen sx_var_dump; do
  if command -v "$helper" >/dev/null 2>&1; then
    printf '準備用APIが混入しています: %s\n' "$helper" >&2
    exit 1
  fi
done
# shellcheck source=/dev/null
. "$2"
shift 2
case "$items" in "${SX_CFG_SIG_ARR}:"*) ;; *) exit 1;; esac
case "$items_len" in 3) ;; *) exit 1;; esac
case "$items_0" in "$1") ;; *) exit 1;; esac
case "$items_1" in "$2") ;; *) exit 1;; esac
case "$items_2" in "$3") ;; *) exit 1;; esac
check_no_leak
sx_arr_splice items 1 1 replacement
case "$items_len" in 3) ;; *) exit 1;; esac
case "$items_0" in "$1") ;; *) exit 1;; esac
case "$items_1" in replacement) ;; *) exit 1;; esac
case "$items_2" in "$3") ;; *) exit 1;; esac
check_no_leak
printf '%s\n' '復元・置換・隔離・漏洩検査: OK'
