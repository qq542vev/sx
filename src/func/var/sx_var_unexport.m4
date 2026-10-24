M_REQUIRE([|SX_CFG_SKIP_CHK __sx_var_is_rw __sx_var_unexport sx_var_is_name|])dnl
pushdef([|CLEANUP|])dnl
### sx_var_unexport - 変数のエクスポート属性を解除する
##
## 使い方:
##   sx_var_unexport 名前1 [名前2 ...]
##
## 説明:
##   指定された変数のエクスポート（export）属性を解除する。変数の値は保持される。
##   POSIX sh には export -n が存在しないため、値を一時保存した上で unset し、
##   再代入することで export 属性を除去する。
##   対象は通常の変数を想定する（sx 配列は対象外。配列要素の一括解除は行わない）。
##   すでに export されていない変数を指定しても成功する（何もしない）。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  読み取り専用などの理由で解除できない変数が含まれる (SX_EX_NOPERM)
sx_var_unexport() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_var_unexport "${@}" || return; return 0;; esac

	sx_var_is_name "${@}" || return M_EX_USAGE

	__sx_var_is_rw "${@}" || return M_EX_NOPERM

	__sx_var_unexport "${@}"
}

popdef([|CLEANUP|])dnl
