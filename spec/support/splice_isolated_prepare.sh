#!/bin/sh
# 準備側だけで補助APIを読み込み、入力配列をシェルコードとして保存する。
# shellcheck source=/dev/null
. "$1"
shift
fixture_path=$1
shift
sx_arr_gen items "$@"
sx_var_dump fixture items
# shellcheck disable=SC2154 # sx_var_dump が参照渡しで設定する。
printf '%s' "$fixture" > "$fixture_path"
