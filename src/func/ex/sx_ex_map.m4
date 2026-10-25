M_REQUIRE([|SX_CFG_SKIP_CHK __sx_ex_map __sx_var_is_bind __sx_var_is_bindable|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_Q([|dnl
### sx_ex_map - 終了ステータスの数値と名前を相互変換、または有効性を確認する
##
## 使い方:
##   sx_ex_map バインド形式 [値1 [値2 ...]]
##
## 説明:
##   終了ステータスの数値（0-255）を対応する名前（OK, USAGE, ...）に、
##   あるいは名前を数値に変換し、結果を指定された変数に格納する。
##   引数が指定されない場合は、バインド形式に基づき変数を初期化する。
##
## バインド形式:
##   - `変数名`: すべての引数の変換結果をスペース区切りで結合して格納する。
##   - `変数名1:変数名2`: 各引数を順番に変換して格納する。詳細は __sx_var_bind_init を参照。
##
## 終了ステータス:
##   - 0 (SX_EX_OK): すべての変換に成功。
##   - 64 (SX_EX_USAGE): バインド形式が無効、無効なステータス、または対応するマッピングが存在しない。
##   - 77 (SX_EX_NOPERM): 書き込み禁止の変数に代入しようとした。
##   - 78 (SX_EX_CONFIG): SX_CFG_NUM_RANGE の値が不正。
##   78  参照する設定値が不正または未設定 (SX_EX_CONFIG)

define([|CLEANUP|], [|Q_bind Q_arg|])dnl

sx_ex_map() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_ex_map "${@}" || return; return;; esac

	M_CFG_CHECK([|sx_ex_map|])

	__sx_var_is_bind "${1-!}" || return M_EX_USAGE

	__sx_var_is_bindable "${1}" || return M_EX_NOPERM

	Q_bind="${1}"
	shift

	for Q_arg in "${@}"; do
		case "${Q_arg}" in
			0 | 6[4-9] | 7[0-8] | OK | USAGE | DATAERR | NOINPUT | NOUSER | NOHOST | UNAVAILABLE | SOFTWARE | OSERR | OSFILE | CANTCREAT | IOERR | TEMPFAIL | PROTOCOL | NOPERM | CONFIG) ;;
			*)
				unset CLEANUP
				return M_EX_USAGE
				;;
		esac
	done

	__sx_ex_map "${Q_bind}" "${@}"
	unset CLEANUP
}
|], [|ex_map|])dnl
popdef([|CLEANUP|])dnl
