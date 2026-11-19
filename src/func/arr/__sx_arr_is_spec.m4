M_REQUIRE([|__sx_num_is_int_base10 __sx_num_is_nzint_base10|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_arr_is_spec - 文字列が配列要素指定 spec として有効か確認する（内部用）
##
## 使い方:
##   __sx_arr_is_spec [spec1 [spec2 ...]]
##
## 説明:
##   sx_arr_is_spec の内部実装。
##   引数チェックは行わない。

define([|CLEANUP|], [|Q_spec Q_rest Q_part|])dnl

__sx_arr_is_spec() {
	case "${*}" in *:*) ;; *)
		__sx_num_is_int_base10 "${@}" || return
		return
	esac

	for Q_spec in "${@}"; do
		case "${Q_spec}" in
			*:*:*)
				Q_part="${Q_spec%%:*}"
				Q_spec="${Q_spec#*:}"
				Q_rest="${Q_spec%%:*}"
				__sx_num_is_int_base10 ${Q_part:+"${Q_part}"} ${Q_rest:+"${Q_rest}"} && __sx_num_is_nzint_base10 "${Q_spec#*:}"
				;;
			*:*)
				Q_part="${Q_spec%:*}"
				Q_rest="${Q_spec#*:}"
				__sx_num_is_int_base10 ${Q_part:+"${Q_part}"} ${Q_rest:+"${Q_rest}"}
				;;
			*) __sx_num_is_int_base10 "${Q_spec}";;
		esac || {
			unset CLEANUP
			return 1
		}
	done

	unset CLEANUP
}
|], [|arr_is_spec|])dnl
popdef([|CLEANUP|])dnl
