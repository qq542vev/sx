dnl 定義と依存宣言はこのファイルで管理する。
M_REQUIRE([|__sx_var_is_arr|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_var_unset - 変数または配列を関連要素を含めて削除する（内部用）
##
## 使い方:
##   __sx_var_unset 名前1 [名前2 ...]
##
## 説明:
##   sx_var_unset の内部実装。
##   引数チェックは行わない。

define([|CLEANUP|], [|Q_len Q_i|])dnl

__sx_var_unset() {
	while M_STR_NE([|"${#}"|], [|0|]); do
		if __sx_var_is_arr "${1}"; then
			eval "Q_len=\"\${${1}_len}\""
			set -- "${@}" "${1}_len"

			Q_i=0
			while M_STR_NE([|"${Q_i}"|], [|"${Q_len}"|]); do
				set -- "${@}" "${1}_${Q_i}"
				M_NUM_INCR([|Q_i|])
			done
		fi

		unset -v "${1}"
		shift
	done

	unset CLEANUP
}
|], [|var_unset|])dnl
popdef([|CLEANUP|])dnl
