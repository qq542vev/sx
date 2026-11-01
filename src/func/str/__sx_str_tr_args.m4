M_REQUIRE([|SX_CFG_SEP __sx_str_tr0|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_str_tr_args - 置換先の引数列とlimitを共通の置換処理へ渡す（内部用）
##
## 使い方:
##   __sx_str_tr_args バインド形式 文字列 from文字列 [置換先 ...]
##   __sx_str_tr_args バインド形式 文字列 from文字列 [limit] ::: [置換先 ...]
##
## 説明:
##   内部実装。引数チェックは行わない。
##   先頭3引数は必須。::: は SX_CFG_SEP の値を使用する。
##   区切りは第4引数、第5引数の順に判定し、それ以降は置換先として保持する。
##   limit を第4引数に固定した形式へ整え、__sx_str_tr0 へ委譲する。
##
## 終了ステータス:
##    0  成功

define([|CLEANUP|], [|Q_bind Q_str Q_from Q_lim|])dnl

__sx_str_tr_args() {
	Q_bind="${1}" Q_str="${2}" Q_from="${3}" Q_lim=

	case "X${SX_CFG_SEP}" in
		"${4+X${4}}") shift 4;;
		"${5+X${5}}") Q_lim="${4}"; shift 5;;
		*) shift 3;;
	esac

	set -- "${Q_bind}" "${Q_str}" "${Q_from}" "${Q_lim}" "${@}"
	unset CLEANUP
	__sx_str_tr0 "${@}"
}
|], [|str_tr_args|])dnl
popdef([|CLEANUP|])dnl
