M_REQUIRE([|SX_CFG_SEP SX_CFG_SKIP_CHK __sx_arg_resize __sx_num_is_nat0_base __sx_num_is_nat0_safe __sx_var_is_bind __sx_var_is_bindable|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_Q([|dnl
### sx_arg_resize - 引数リストを指定された形状にリサイズする
##
## 使い方:
##   sx_arg_resize bind [shape [pad_val [flag]]] ::: [arg ...]
##   sx_arg_resize bind [shape [arg ...]]
##
## 説明:
##   与えられた引数リスト [arg ...] を、指定された shape の総要素数に
##   リサイズする。要素が不足している場合は pad_val で埋め、
##   超過している場合は切り詰める。
##
##   shape は ":" 区切りの多次元形式で指定する。
##     2:3   → 2行×3列 = 6要素
##     2:3:4 → 2行×3列×4層 = 24要素
##   いずれかの軸に -1 を指定すると、その軸のサイズを
##   切り上げ ceil(要素数 / 既知の軸の積) で自動計算する。
##   ただし -1 は1つまで。各軸は先行ゼロのない非負の10進整数、または -1。
##   軸のサイズと総要素数は多倍長に対応する。既知の軸の積が0なら推論値も0。
##   分配先が尽きた時点で生成を終了する。
##
##   flag には以下のビットマスクを指定できる（省略時は 0）:
##     SX_ARG_RESIZE_PAD_LEFT (2) — 不足要素を左側に詰める
##
##   2 つの呼び出し形式がある:
##     1) ::: 形式: bind/shape/val/flag を ::: より前の位置引数で指定し、
##        ::: 以降をデータとして扱う。設定引数とデータを明確に分離できる。
##     2) 簡略形式: 第一引数が bind、第二引数が shape、第三引数以降がデータ
##        となる。pad_val は空文字列、flag は 0 とする。
##   bind は必須（空文字列可）。shape の省略時・空指定時はデータの個数を使用し、
##   リサイズせずクォートする。
##   ::: は SX_CFG_SEP の値を使用する。データ先頭付近にその値を含む場合は、
##   ::: 形式で境界を明示する。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正、shape または flag の形式が不正 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
##   78  参照する設定値が不正または未設定 (SX_EX_CONFIG)

define([|CLEANUP|], [|Q_shape Q_dim Q_inferred|])dnl

sx_arg_resize() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_arg_resize "${@}" || return; return;; esac

	M_CFG_CHECK([|sx_arg_resize|])

	__sx_var_is_bind "${1-!}" || return M_EX_USAGE

	__sx_var_is_bindable "${1}" || return M_EX_NOPERM

	Q_shape=
	case "X${SX_CFG_SEP}" in
		"${2+X${2}}") ;;
		"${3+X${3}}" | "${4+X${4}}") Q_shape="${2}";;
		"${5+X${5}}")
			__sx_num_is_nat0_safe "${4:-}" || {
				unset CLEANUP
				return M_EX_USAGE
			}
			Q_shape="${2}"
			;;
			*) Q_shape="${2-}";;
	esac

	Q_inferred=0
	case "${Q_shape}" in '') Q_shape=0;; esac
	while :; do
		Q_dim="${Q_shape%%:*}"
		case "${Q_dim}:${Q_inferred}" in
			-1:0) Q_inferred=1;;
			*) __sx_num_is_nat0_base 10 "${Q_dim}" || {
				unset CLEANUP
				return M_EX_USAGE
			};;
		esac
		case "${Q_shape}" in *:*) Q_shape="${Q_shape#*:}";; *) break;; esac
	done

	unset CLEANUP

	__sx_arg_resize "${@}"
}
|], [|arg_resize|])dnl
popdef([|CLEANUP|])dnl
