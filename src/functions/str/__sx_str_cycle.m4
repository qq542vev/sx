dnl 定義と依存宣言はこのファイルで管理する。
M_REQUIRE([|__sx_num_divmod_nat0 __sx_str_chunk __sx_str_rchunk|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_str_cycle - sx_str_cycle の内部実装（内部用）
##
## 使い方:
##   __sx_str_cycle 結果変数名 [元文字列 [シフト量]]
##
## 説明:
##   sx_str_cycle の内部実装。引数チェックは行わない。

define([|CLEANUP|], [|Q_head Q_tail Q_str Q_len Q_shift Q_mod|])dnl

__sx_str_cycle() {
	set -- "${1}" "${2-}" "${3:-1}"
	Q_str="${2-}"
	Q_len="${#Q_str}"
	Q_shift="${3:-1}"

	case "${Q_str:+${Q_shift}}" in '' | 0 | [+-]0)
		M_VAR_SET([|${1}|], [|${2}|])
		unset CLEANUP
		return
	esac

	__sx_num_divmod_nat0 :Q_mod: "${Q_shift#[+-]}" "${Q_len}"

	case "${Q_mod}" in 0)
		M_VAR_SET([|${1}|], [|${2}|])
		unset CLEANUP
		return
	esac

	case "${Q_shift}" in
		-*) __sx_str_rchunk Q_tail:Q_head: "${2}" "${Q_mod}" 1;;
		*) __sx_str_chunk Q_head:Q_tail: "${2}" "${Q_mod}" 1;;
	esac

	M_VAR_SET([|${1}|], [|${Q_tail}${Q_head}|])

	unset CLEANUP
}
|], [|str_cycle|])dnl
popdef([|CLEANUP|])dnl
