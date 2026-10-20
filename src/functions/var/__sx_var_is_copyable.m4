M_REQUIRE([|__sx_var_is_rw_deep|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_var_is_copyable - コピー先が構造を含めて書き込み可能か確認する（内部用）
##
## 使い方:
##   __sx_var_is_copyable [連鎖式1 [連鎖式2 ...]]
##
## 説明:
##   sx_var_is_copyable の内部実装。
##   引数チェックは行わない。
##   「名前_*」形式の変数は暗黙的に「名前」に属するとみなすため、
##   __sx_var_is_rw_deep により配下の変数も含めて確認する。

define([|CLEANUP|], [|Q_ls Q_arg|])dnl

__sx_var_is_copyable() {
	Q_ls=''

	for Q_arg in "${@}"; do
		case "${Q_arg}" in
			*=*) Q_arg="${Q_arg%[=-]*}";;
			*-*) Q_arg="${Q_arg#*[=-]}";;
			*) continue;;
		esac

		while M_STR_MATCH([|"${Q_arg}"|], [|*[=-]*|]); do
			M_STR_APPEND([|Q_ls|], [|" ${Q_arg%%[=-]*}"|])
			Q_arg="${Q_arg#*[=-]}"
		done

		M_STR_APPEND([|Q_ls|], [|" ${Q_arg}"|])
	done

	eval set -- "${Q_ls}"
	unset CLEANUP

	__sx_var_is_rw_deep "${@}" || return
}
|], [|var_is_copyable|])dnl
popdef([|CLEANUP|])dnl
