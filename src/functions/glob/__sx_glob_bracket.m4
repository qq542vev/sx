dnl 定義と依存宣言はこのファイルで管理する。
M_REQUIRE([|__sx_str_tr|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_glob_bracket - 文字セットを glob ブラケット式で安全な形に並べ替える（内部用）
##
## 使い方:
##   __sx_glob_bracket 結果変数名 文字セット
##
## 説明:
##   sx_glob_bracket の内部実装。引数チェックは行わない。
##
## 終了ステータス:
##   常に 0 (SX_EX_OK)

define([|CLEANUP|], [|Q_pre Q_suf Q_c Q_rest|])dnl

__sx_glob_bracket() {
	case "${2}" in
		*[!^!]*) ;;
		!*^* | ^*!*)
			M_VAR_SET([|${1}|], [|[[.!.]^]|])
			return M_EX_OK
			;;
		*)
			M_VAR_SET([|${1}|], [|${2%"${2#?}"}|])
			return M_EX_OK
	esac

	case "${2}" in *']'*)
		Q_pre=']'
	esac

	case "${2}" in *'\'*)
		Q_suf='\\'
	esac

	for Q_c in = . : '!' '^' -; do
		case "${2}" in *"${Q_c}"*)
			Q_suf="${Q_suf-}${Q_c}"
		esac
	done

	 __sx_str_tr Q_rest: "${2}" ']\.:=!^-'

	M_STR_WRAP([|Q_rest|], [|"${Q_pre-}"|], [|"${Q_suf-}"|])

	case "${Q_rest}" in '!-' | '^-' | '!^-')
		Q_rest="-${Q_rest%-}"
	esac

	M_VAR_SET([|${1}|], [|[${Q_rest}]|])

	unset CLEANUP
}
|], [|glob_bracket|])dnl
popdef([|CLEANUP|])dnl
