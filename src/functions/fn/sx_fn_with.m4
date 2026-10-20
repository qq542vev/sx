M_REQUIRE([|SX_CFG_SEP SX_CFG_SKIP_CHK __sx_arg_quote __sx_fn_with sx_fn_is_valid|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_Q([|dnl
### sx_fn_with - 一時的な匿名関数を定義してコマンドを実行する
##
## 使い方:
##   sx_fn_with [エイリアス=本体 ...] [${SX_CFG_SEP}] コマンド [引数 ...]
##
## 説明:
##   指定されたエイリアス名で一時的な関数を定義し、コマンドを実行する。
##   コマンドの引数の中にエイリアス名と一致するものがあれば、生成された一意な名前に置換される。
##   コマンドの実行終了後、定義された関数は自動的に削除される。

define([|CLEANUP|], [|Q_i Q_arg Q_fn|])dnl

sx_fn_with() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_fn_with "${@}" || return; return;; esac

	Q_i=0
	for Q_arg in "${@}"; do
		case "${Q_arg}" in
			"${SX_CFG_SEP-}") break;;
			*=*) ;;
			*) break;;
		esac

		M_NUM_INCR([|Q_i|])
	done

	case "${Q_i}" in [!0]*)
		__sx_arg_quote "${Q_i}Q_fn:" "${@}"

		eval sx_fn_is_valid "${Q_fn}" || {
			unset CLEANUP
			return M_EX_USAGE
		}
	esac

	unset CLEANUP

	__sx_fn_with "${@}" || return
}
|], [|fn_with|])dnl
popdef([|CLEANUP|])dnl
