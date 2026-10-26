M_REQUIRE([|__sx_str_is_of|])dnl
### __sx_str_is_alund - すべての引数が英字とアンダースコアのみで構成されているか確認する（内部用）
##
## 使い方:
##   __sx_str_is_alund [文字列1 [文字列2 ...]]
##
## 説明:
##   内部実装。引数チェックは行わない。
##
## 終了ステータス:
##    0  すべて英字とアンダースコアのみで構成されている (SX_EX_OK)
##    1  それ以外の文字が含まれる、または空文字列が含まれる

__sx_str_is_alund() {
	__sx_str_is_of M_SH_QUOTE(M_STR_ALUND) "${@}" || return
}
