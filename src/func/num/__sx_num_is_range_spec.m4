M_REQUIRE([||])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_num_is_range_spec - すべての引数が range spec として有効か確認する（内部用）
##
## 使い方:
##   __sx_num_is_range_spec [spec1 [spec2 ...]]
##
## 説明:
##   sx_num_is_range_spec の内部実装。
##   引数チェックは行わない。
##   受理する形式: 整数 | [始点]:終点[:刻み]
##   整数は符号付き10進整数（+1 / -1 の接頭辞可、前ゼロなし、-0 は 0 とみなす）。
##   コロン形式では終点は必須。始点は省略可。刻みは第2コロンがある場合に必須で、0 以外の整数。
##
## 終了ステータス:
##    0  すべて有効な形式である (SX_EX_OK)
##    1  無効な形式が含まれる

define([|CLEANUP|], [|Q_arg|])dnl

__sx_num_is_range_spec() {
	for Q_arg in "${@}"; do
		case "${Q_arg}" in ''|*[!0-9]|[!+1-:-][!:]*|*[!:][!0-:]*|*[!0-9][!+1-9-][!:]*|*[!+0-9-]*?[!0-9][!+1-9-]*|*[!+0-9-]*[!+0-9-]?*[!0-9]*)
			unset CLEANUP
			return 1
		esac
	done

	unset CLEANUP
}
|], [|num_is_range_spec|])dnl
popdef([|CLEANUP|])dnl
