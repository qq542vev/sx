M_REQUIRE([|SX_CFG_NUM_RANGE __sx_num_add1_arith __sx_num_add1_nat0 __sx_num_cmp_arith __sx_num_cmp_nat0 __sx_num_is_int_fit_dec __sx_num_sub_arith __sx_num_sub_nat0 __sx_var_bind|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_arg_pad_cb - 引数リストをコールバックでパディングする（内部用）
##
## 使い方:
##   __sx_arg_pad_cb スキーマ 長さ コールバック フラグ [値 ...]
##
## 説明:
##   sx_arg_pad のコールバックモード実装。パディング値の代わりに
##   コールバック関数を呼び出し、その戻り値をパディング値として使用する。
##   コールバック契約: cb ret_var idx cnt skip
##    cnt は 1-based。
##
##   コールバックが ret_var を unset した場合、そのスロットはスキップされる。
##   コールバックが非0を返した場合、処理を中断する。
##
##   内部実装。引数チェックは行わない。
##   長さの絶対値と元の個数が算術域内なら算術、それ以外は多倍長で更新する。
##   出力済み個数・処理済みスロット数を0から管理し、必要なときだけ増やす。
##   必要スロット数は固定し、処理済みスロット数との文字列比較で終了する。
##   左パディング・元の値の一括結合・右パディングの3段階で処理する。
##   状態は位置変数に保存し、一時変数を解放してからコールバックを呼ぶ。
##   コールバック結果には固定の Q_ret を使用する。
##   コールバックは途中の処理を別変数で行い、末尾で結果変数に単純代入する。
##   結果変数を他の関数の結果変数・バインド先として渡してはならない。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   非0  最初に失敗したコールバックの終了ステータス

define([|CLEANUP|], [|Q_bind Q_len Q_cb Q_size Q_type Q_needed Q_ret Q_i Q_cnt Q_skip Q_ex|])dnl

__sx_arg_pad_cb() {
	Q_bind="${1}" Q_len="${2}" Q_cb="${3}" Q_needed=0
	shift 4
	Q_size="${#}"

	if __sx_num_is_int_fit_dec "${SX_CFG_NUM_RANGE}" "${Q_len#[+-]}" "${Q_size}"; then
		Q_type=arith
	else
		Q_type=nat0
	fi

	"__sx_num_cmp_${Q_type}" "${Q_len#[+-]}" "${Q_size}" || case "${?}" in 3)
		"__sx_num_sub_${Q_type}" Q_needed "${Q_len#[+-]}" "${Q_size}"
	esac

	# $1: 出力済み個数、$2: 処理済みスロット数、$3: skip、$4: 必要スロット数（固定）、$5: bind
	# $6: 数値経路、$7: callback、$8以降: 元の値
	set -- 0 0 0 "${Q_needed}" "${Q_bind}" "${Q_type}" "${Q_cb}" "${@}"

	# 左パディング
	case "${Q_len}" in -*)
		while M_STR_NE([|"${2}"|], [|"${4}"|]) && M_STR_NE([|"${5}"|], [|''|]); do
			"__sx_num_add1_${6}" Q_i "${1}"
			"__sx_num_add1_${6}" Q_cnt "${2}"
			set -- "${Q_i}" "${Q_cnt}" "${@}"
			unset CLEANUP

			"${9}" Q_ret "${1}" "${2}" "${5}" || {
				Q_ex="${?}" Q_bind="${7}"
				shift 9
				# 左パディングの失敗時も、元の値はバインドが続く限り結合する。
				__sx_var_bind '' "${Q_bind}" "${@}" || :
				set -- "${Q_ex}"
				unset CLEANUP
				return "${1}"
			}

			Q_i="${3}" Q_cnt="${2}" Q_skip="${5}" Q_cb="${9}"

			case "${Q_ret+X}" in
				X)
					__sx_var_bind Q_bind "${7}" "${Q_ret}"
					Q_i="${1}"
					;;
				*)
					Q_bind="${7}"
					"__sx_num_add1_${8}" Q_skip "${5}"
					;;
			esac

			eval 'shift 9;' set -- "${Q_i}" "${Q_cnt}" "${Q_skip}" "${6}" '"${Q_bind}"' "${8}" '"${Q_cb}"' '"${@}"'
		done
	esac

	# 元の値を一括結合する。バインド枯渇時は後続のコールバックを呼ばない。
	Q_cnt="${2}" Q_skip="${3}" Q_needed="${4}" Q_bind="${5}" Q_type="${6}" Q_cb="${7}"
	shift 7

	__sx_var_bind Q_bind "${Q_bind}" "${@}" || {
		unset CLEANUP
		return
	}

	# 左側で完了した場合は処理済み数が必要数と等しいため、右側では実行しない。
	# 右側の出力済み個数は元の個数そのものなので、要素ごとの加算は不要。
	set -- "${#}" "${Q_cnt}" "${Q_skip}" "${Q_needed}" "${Q_bind}" "${Q_type}" "${Q_cb}"

	# 右パディング
	while M_STR_NE([|"${2}"|], [|"${4}"|]) && M_STR_NE([|"${5}"|], [|''|]); do
		"__sx_num_add1_${6}" Q_i "${1}"
		"__sx_num_add1_${6}" Q_cnt "${2}"
		set -- "${Q_i}" "${Q_cnt}" "${@}"
		unset CLEANUP

		"${9}" Q_ret "${1}" "${2}" "${5}" || {
			set -- "${?}"
			unset CLEANUP
			return "${1}"
		}

		Q_i="${3}" Q_cnt="${2}" Q_skip="${5}"

		case "${Q_ret+X}" in
			X)
				__sx_var_bind Q_bind "${7}" "${Q_ret}"
				Q_i="${1}"
				;;
			*)
				Q_bind="${7}"
				"__sx_num_add1_${8}" Q_skip "${5}"
				;;
		esac

		set -- "${Q_i}" "${Q_cnt}" "${Q_skip}" "${6}" "${Q_bind}" "${8}" "${9}"
	done

	unset CLEANUP
}
|], [|arg_pad_cb|])dnl
popdef([|CLEANUP|])dnl
