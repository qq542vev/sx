M_REQUIRE([|SX_CFG_SKIP_CHK __sx_arg_range __sx_num_is_slice __sx_var_is_name __sx_var_is_rw|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_Q([|dnl
### sx_arg_range - 位置パラメータの参照文字列を範囲指定で生成する
##
## 使い方:
##   sx_arg_range 結果変数名 区切り文字 [spec ...]
##
## 説明:
##   各 spec（整数 | [始点]:終点[:刻み]）を sx_num_range と同一の規則で解釈し、
##   生成されたインデックスのうち 1 以上のものを "${インデックス}" 形式の
##   参照文字列に変換して区切り文字で結合し、結果変数に格納する。
##   0 と負のインデックスは範囲計算には用いるが、出力からは除外する。
##   単体整数 N は 0:N として扱う。始点省略は 0、刻み省略は 1。
##   コロン形式では終点は必須。第2コロンを書いた場合は刻みが必須であり、
##   刻みは 0 以外でなければならない。終了値は含まない (exclusive)。
##   区切り文字は任意の文字列であり、パターン文字もリテラルとして扱う。
##   参照が1つの場合は区切り文字を含めない。範囲が空なら空文字列を格納する。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
##   78  参照する設定値が不正または未設定 (SX_EX_CONFIG)

define([|CLEANUP|], [|Q_res Q_sep|])dnl

sx_arg_range() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_arg_range "${@}" || return; return;; esac

	M_CFG_CHECK([|sx_arg_range|])

	__sx_var_is_name "${1-}" || return M_EX_USAGE

	__sx_var_is_rw "${1}" || return M_EX_NOPERM

	Q_res="${1}"
	Q_sep="${2-}"
	shift ${2+'2'}

	__sx_num_is_slice "${@}" || {
		unset CLEANUP
		return M_EX_USAGE
	}

	__sx_arg_range "${Q_res}" "${Q_sep}" "${@}"
	unset CLEANUP
}
|], [|arg_range|])dnl
popdef([|CLEANUP|])dnl
