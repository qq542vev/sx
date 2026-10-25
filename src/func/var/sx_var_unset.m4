M_REQUIRE([|SX_CFG_SKIP_CHK __sx_var_is_name __sx_var_is_rw_all __sx_var_unset|])dnl
pushdef([|CLEANUP|])dnl
### sx_var_unset - 変数または配列を関連要素を含めて削除する
##
## 使い方:
##   sx_var_unset 名前1 [名前2 ...]
##
## 説明:
##   指定された変数を削除する。対象がsx配列である場合は、その要素および
##   長さ変数も含めて再帰的にすべて削除する。
##   一つでも削除不可能な変数（読み取り専用など）が含まれる場合は、
##   どの変数も削除せずにエラーを返す。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  削除不可能な変数が含まれる (SX_EX_NOPERM)
sx_var_unset() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_var_unset "${@}" || return; return 0;; esac

	__sx_var_is_name "${@}" || return M_EX_USAGE

	__sx_var_is_rw_all "${@}" || return M_EX_NOPERM

	__sx_var_unset "${@}"
}

popdef([|CLEANUP|])dnl
