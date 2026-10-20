M_REQUIRE([|__sx_num_cmp_nat0 __sx_str_qm|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_str_rev - 文字列を反転する（内部用）
##
## 使い方:
##   __sx_str_rev 結果変数名 [元文字列 [チャンクサイズ]]
##
## 説明:
##   sx_str_rev の内部実装。引数チェックは行わない。
##   チャンクサイズは 0 以外の10進整数表記（任意の符号付き、先行する 0 なし）を前提とする。
##   チャンクサイズが正の場合は先頭基準、負の場合は末尾基準でチャンク単位の反転を行う。

define([|CLEANUP|], [|Q_src Q_size Q_out Q_pat Q_tmp|])dnl

__sx_str_rev() {
	Q_src="${2-}"
	Q_size="${3:-1}"
	Q_out=

	__sx_num_cmp_nat0 "${#Q_src}" "${Q_size#[+-]}" || case "${?}" in [12])
		M_VAR_SET([|${1}|], [|${Q_src}|])
		unset CLEANUP
		return
	esac

	__sx_str_qm Q_pat "${Q_size#[+-]}"

	case "${Q_size}" in
		-*)
			while M_STR_MATCH([|"${Q_src}"|], [|${Q_pat}?*|]); do
				Q_tmp="${Q_src%${Q_pat}}"
				M_STR_APPEND([|Q_out|], [|"${Q_src#"${Q_tmp}"}"|])
				Q_src="${Q_tmp}"
			done

			M_VAR_SET([|${1}|], [|${Q_out}${Q_src}|])
			;;
		*)
			while M_STR_MATCH([|"${Q_src}"|], [|${Q_pat}?*|]); do
				Q_tmp="${Q_src#${Q_pat}}"
				M_STR_PREPEND([|Q_out|], [|"${Q_src%"${Q_tmp}"}"|])
				Q_src="${Q_tmp}"
			done

			M_VAR_SET([|${1}|], [|${Q_src}${Q_out}|])
			;;
	esac

	unset CLEANUP
}
|], [|str_rev|])dnl
popdef([|CLEANUP|])dnl
