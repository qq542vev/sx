
### sx_str_len - 文字列の長さを取得する
##
## 使い方:
##   1. sx_str_len 結果変数名 [文字列 ...]
##   2. sx_str_len 変数名=文字列 [変数名=文字列 ...]
##
## 説明:
##   使い方1の場合、後続の各文字列の長さをスペース区切りで結合して結果変数に格納する。
##   文字列が1つだけの場合は、その長さのみが格納される。
##   使い方2の場合、各変数にそれぞれの文字列の長さを格納する。
##
##   現在のロケール設定（LC_ALL 等）に従って文字数をカウントする。
##   バイト数が必要な場合は LC_ALL=C を前置して呼び出す。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
sx_str_len() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_str_len "${@}" || return; return 0;; esac

	case "${1-}" in
		*=*)
			__sx_str_len_chk=
			for __sx_str_len_arg in "${@}"; do
				sx_var_is_name "${__sx_str_len_arg%%=*}" || {
					unset __sx_str_len_arg __sx_str_len_chk
					return "${SX_EX_USAGE}"
				}
				__sx_str_len_chk="${__sx_str_len_chk} ${__sx_str_len_arg%%=*}"
			done
			eval sx_var_rw_chk "${__sx_str_len_chk}" || {
				set -- "${?}"
				unset __sx_str_len_arg __sx_str_len_chk
				return "${1}"
			}
			unset __sx_str_len_arg __sx_str_len_chk
			;;
		*)
			sx_var_rw_chk "${1-}" || return
			;;
	esac

	__sx_str_len "${@}"
}

### __sx_str_len - 文字列の長さを取得する（内部用）
##
## 使い方:
##   __sx_str_len ... (引数は sx_str_len に準ずる)
##
## 説明:
##   引数チェックを行わずに文字列の長さを取得する。
__sx_str_len() {
	case "${1-}" in
		*=*)
			for __sx_str_len_arg_ in "${@}"; do
				__sx_str_len_var_="${__sx_str_len_arg_%%=*}"
				__sx_str_len_val_="${__sx_str_len_arg_#*=}"
				eval "${__sx_str_len_var_}=\${#__sx_str_len_val_}"
			done
			unset __sx_str_len_arg_ __sx_str_len_var_ __sx_str_len_val_
			;;
		*)
			__sx_str_len_res_="${1}"
			shift
			__sx_str_len_out_=
			for __sx_str_len_arg_ in "${@}"; do
				__sx_str_len_out_="${__sx_str_len_out_} ${#__sx_str_len_arg_}"
			done
			eval "${__sx_str_len_res_}=\${__sx_str_len_out_# }"
			unset __sx_str_len_res_ __sx_str_len_out_ __sx_str_len_arg_
			;;
	esac
}

