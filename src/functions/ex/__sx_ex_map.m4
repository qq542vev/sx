dnl 本体は sx.m4 から生成。依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_EX_CANTCREAT SX_EX_CONFIG SX_EX_DATAERR SX_EX_IOERR SX_EX_MSG0 SX_EX_MSG64 SX_EX_MSG65 SX_EX_MSG66 SX_EX_MSG67 SX_EX_MSG68 SX_EX_MSG69 SX_EX_MSG70 SX_EX_MSG71 SX_EX_MSG72 SX_EX_MSG73 SX_EX_MSG74 SX_EX_MSG75 SX_EX_MSG76 SX_EX_MSG77 SX_EX_MSG78 SX_EX_NOHOST SX_EX_NOINPUT SX_EX_NOPERM SX_EX_NOUSER SX_EX_OK SX_EX_OSERR SX_EX_OSFILE SX_EX_PROTOCOL SX_EX_SOFTWARE SX_EX_STS0 SX_EX_STS64 SX_EX_STS65 SX_EX_STS66 SX_EX_STS67 SX_EX_STS68 SX_EX_STS69 SX_EX_STS70 SX_EX_STS71 SX_EX_STS72 SX_EX_STS73 SX_EX_STS74 SX_EX_STS75 SX_EX_STS76 SX_EX_STS77 SX_EX_STS78 SX_EX_TEMPFAIL SX_EX_UNAVAILABLE SX_EX_USAGE __sx_var_bind_init __sx_var_ubind|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_ex_map - 終了ステータスの数値と名前を相互変換、または有効性を確認する（内部用）
##
## 使い方:
##   __sx_ex_map バインド形式 [値1 [値2 ...]]
##
## 説明:
##   sx_ex_map の内部実装。
##   引数チェックを行わずに変換処理を行う。

define([|CLEANUP|], [|Q_bind Q_arg|])dnl

__sx_ex_map() {
	__sx_var_bind_init "${1}"
	Q_bind="${1}"
	shift

	for Q_arg in "${@}"; do
		case "${Q_arg}" in
			[0-9]*) eval __sx_var_ubind Q_bind '"${Q_bind}"' "\"\${SX_EX_STS${Q_arg}}\"";;
			*) eval __sx_var_ubind Q_bind '"${Q_bind}"' "\"\${SX_EX_${Q_arg}}\"";;
		esac || break
	done

	unset CLEANUP
}
|], [|ex_map|])dnl
popdef([|CLEANUP|])dnl
