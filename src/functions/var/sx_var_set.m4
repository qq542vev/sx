dnl 定義と依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_CFG_SKIP_CHK __sx_var_set sx_var_is_name sx_var_is_rw_all|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_Q([|dnl
### sx_var_set - 変数に値を設定、または削除する
##
## 使い方:
##   sx_var_set [名前=値 | 名前 ...]
##
## 説明:
##   指定された変数に値を設定する。= を含まない名前のみが指定された場合は、
##   その変数を削除（unset）する。対象が sx 配列である場合は、
##   関連するすべての要素（_len, _0, _1...）も再帰的に削除される。
##
## 注意:
##   内部関数は結果変数への代入時に事前 unset を行わないため、
##   sx 配列が格納された変数を結果変数として使う場合は、
##   事前に sx_var_unset を明示的に呼び出してから関数を呼び出すこと。
##   これを怠ると、古い配列要素（_len, _0, _1...）が残存する。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  読み取り専用変数への操作失敗 (SX_EX_NOPERM)

define([|CLEANUP|], [|Q_arg Q_chk|])dnl

sx_var_set() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_var_set "${@}" || return; return 0;; esac

	Q_chk=

	for Q_arg in "${@}"; do
		sx_var_is_name "${Q_arg%%=*}" || {
			unset Q_arg Q_chk
			return M_EX_USAGE
		}

		M_STR_APPEND([|Q_chk|], [|" ${Q_arg%%=*}"|])
	done

	eval sx_var_is_rw_all "${Q_chk}" || {
		unset  Q_chk Q_arg
		return M_EX_NOPERM
	}

	unset  Q_chk Q_arg
	__sx_var_set "${@}"
}
|], [|var_set|])dnl
popdef([|CLEANUP|])dnl
