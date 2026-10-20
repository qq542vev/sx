M_REQUIRE([|__sx_num_divmod_arith __sx_var_bind_init __sx_var_ubind|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_num_edivmod_arith - 算術展開でユークリッド除算の商と余剰を求める（内部用）
##
## 使い方:
##   __sx_num_edivmod_arith バインド形式 [被除数 [除数]]
##
## 説明:
##   sx_num_edivmod_arith の内部実装。引数チェックは行わない。
##   前提: 設定と入力が有効で、除数は非ゼロ、商は設定幅内に収まること。
##   省略・空文字列の被除数は0、除数は1とし、余分な引数は無視する。
##   __sx_num_divmod_arith の余剰が負の場合のみ、除数の符号に応じて補正する。
##   正の除数なら q -= 1、r += v、負の除数なら q += 1、r -= v とする。
##   補正時は |v| >= 2 で商に増減の余地があり、補正後の余剰は 0 < r < |v|。
##   余剰は最大でもMAXとなり、補正による桁溢れは起きない。
##   全算術は名前参照で行い、MINの絶対値・符号反転・積は求めない。
##   最終バインド先は計算・補正後に初期化し、バインド枯渇は成功とする。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)

define([|CLEANUP|], [|Q_q Q_r Q_v|])dnl

__sx_num_edivmod_arith() {
	Q_v="${3:-1}"
	__sx_num_divmod_arith 'Q_q:Q_r:' "${2:-0}" "${Q_v}"
	__sx_var_bind_init "${1}"

	case "$(((Q_r < 0) ? (0 < Q_v) : 2))" in
		2) __sx_var_ubind '' "${1}" "${Q_q}" "${Q_r}";;
		1) __sx_var_ubind '' "${1}" "$((Q_q - 1))" "$((Q_r + Q_v))";;
		*) __sx_var_ubind '' "${1}" "$((Q_q + 1))" "$((Q_r - Q_v))";;
	esac || :

	unset CLEANUP
}
|], [|num_edivmod_arith|])dnl
popdef([|CLEANUP|])dnl
