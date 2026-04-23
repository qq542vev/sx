#!/bin/sh
# shellcheck shell=sh

# sysexits(3) compatible exit codes
readonly SX_EX_OK=0           # EX_OK: successful termination
readonly SX_EX_USAGE=64        # EX_USAGE: command line usage error
readonly SX_EX_DATAERR=65      # EX_DATAERR: data format error
readonly SX_EX_NOINPUT=66      # EX_NOINPUT: cannot open input
readonly SX_EX_NOUSER=67       # EX_NOUSER: addressee unknown
readonly SX_EX_NOHOST=68       # EX_NOHOST: host name unknown
readonly SX_EX_UNAVAILABLE=69  # EX_UNAVAILABLE: service unavailable
readonly SX_EX_SOFTWARE=70     # EX_SOFTWARE: internal software error
readonly SX_EX_OSERR=71        # EX_OSERR: system error (e.g., can't fork)
readonly SX_EX_OSFILE=72       # EX_OSFILE: critical OS file missing
readonly SX_EX_CANTCREAT=73    # EX_CANTCREAT: can't create (user) output file
readonly SX_EX_IOERR=74        # EX_IOERR: input/output error
readonly SX_EX_TEMPFAIL=75     # EX_TEMPFAIL: temp failure; user is invited to retry
readonly SX_EX_PROTOCOL=76     # EX_PROTOCOL: remote error in protocol
readonly SX_EX_NOPERM=77       # EX_NOPERM: permission denied
readonly SX_EX_CONFIG=78       # EX_CONFIG: configuration error

readonly SX_CHAR_LF='
'
readonly SX_CHAR_TAB='	'
readonly SX_CHAR_CR=''

# 数値定数 (32bit / 64bit 整数限界)
readonly SX_NUM_I32_MAX=2147483647
readonly SX_NUM_I32_MIN=-2147483648
readonly SX_NUM_U32_MAX=4294967295
readonly SX_NUM_I64_MAX=9223372036854775807
readonly SX_NUM_I64_MIN=-9223372036854775808
readonly SX_NUM_U64_MAX=18446744073709551615

# 浮動小数点数限界 (IEEE 754 準拠)
readonly SX_NUM_DBL_MAX='1.7976931348623157e+308'
readonly SX_NUM_DBL_MIN='2.2250738585072014e-308'
readonly SX_NUM_DBL_EPSILON='2.2204460492503131e-16'
readonly SX_NUM_FLT_MAX='3.402823466e+38'
readonly SX_NUM_FLT_MIN='1.175494351e-38'
readonly SX_NUM_FLT_EPSILON='1.192092896e-07'

# 数学定数 (bc などの外部コマンド利用時用)
readonly SX_NUM_PI='3.14159265358979323846'
readonly SX_NUM_TAU='6.28318530717958647692'
readonly SX_NUM_E='2.71828182845904523536'
readonly SX_NUM_SQRT2='1.41421356237309504880'
readonly SX_NUM_SQRT3='1.73205080756887729352'
readonly SX_NUM_SQRT5='2.23606797749978969640'
readonly SX_NUM_PHI='1.61803398874989484820'
readonly SX_NUM_LN2='0.69314718055994530941'
readonly SX_NUM_LN10='2.30258509299404568401'

# 配列を識別するためのシグネチャ。外部コマンドに依存せず、十分に長く複雑な値をデフォルトとする。
: "${SX_SIG_BASE:=sx-sig-27c9d9d5-763d-4c3e-862d-a2f270928a38-5f8a2b1c}"
: "${SX_SIG_ARR:=array-${SX_SIG_BASE}}"
SX_SYS_REV=0

### sx_var_touch - リビジョン番号を更新する
##
## 使い方:
##   sx_var_touch 変数名
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  変数が読み取り専用 (SX_EX_NOPERM)
sx_var_touch() {
	sx_var_rw_chk "${@}" || return "${?}"

	__sx_var_touch "${@}"
}

### __sx_var_touch - 変数のリビジョン番号を更新する（内部用）
##
## 使い方:
##   __sx_var_touch 変数名1 [変数名2 ...]
##
## 説明:
##   指定された変数の値に含まれるリビジョン番号（末尾の : 以降）を
##   現在の SX_SYS_REV で更新し、SX_SYS_REV をインクリメントする。
##   引数チェックは行わない。
__sx_var_touch() {
	for __sx_var_touch_arg_ in "${@}"; do
		eval "${__sx_var_touch_arg_}=\"\${${__sx_var_touch_arg_}%:*}:\${SX_SYS_REV}\""
		SX_SYS_REV=$((SX_SYS_REV + 1))
	done

	unset __sx_var_touch_arg_
}

### sx_call_with_ifs - IFS を一時的に変更してコマンドを実行する
##
## 使い方:
##   sx_call_with_ifs 新しいIFS コマンド [引数 ...]
##
## 説明:
##   指定された IFS のもとで、残りの引数を単語分割（Word Splitting）を伴って実行する。
##
## 終了ステータス:
##    0  実行したコマンドが成功
##   64  引数不正 (SX_EX_USAGE)
##   77  IFS が書き込み不可 (SX_EX_NOPERM)
##   その他  実行したコマンドの終了ステータス
sx_call_with_ifs() {
	sx_str_eq "${2:+X}" X || return "${SX_EX_USAGE}"
	__sx_var_is_rw IFS || return "${SX_EX_NOPERM}"

	__sx_call_with_ifs "${@}" || return "${?}"
}

### __sx_call_with_ifs - IFS を一時的に変更してコマンドを実行する（内部用）
##
## 使い方:
##   __sx_call_with_ifs 新しいIFS コマンド [引数 ...]
##
## 説明:
##   指定された IFS のもとで、残りの引数を単語分割（Word Splitting）を伴って実行する。
##   終了ステータスは実行したコマンドの終了ステータスに従う。
__sx_call_with_ifs() {
	__sx_call_with_ifs_old_="${IFS-}"
	__sx_call_with_ifs_set_="${IFS+X}"
	__sx_call_with_ifs_opts_="${-}"
	__sx_call_with_ifs_cmd_="${2}"
	IFS="${1}"
	shift 2

	set -f
	set -- "${__sx_call_with_ifs_cmd_}" ${*}

	if ! sx_str_has "${__sx_call_with_ifs_opts_}" f; then
		set +f
	fi

	if sx_str_eq "${__sx_call_with_ifs_set_}" X; then
		IFS="${__sx_call_with_ifs_old_}"
	else
		unset IFS
	fi

	unset __sx_call_with_ifs_old_ __sx_call_with_ifs_set_ __sx_call_with_ifs_opts_ __sx_call_with_ifs_cmd_
	"${@}" || return "${?}"
}

### sx_var_is_rw_all - 指定された変数およびその関連要素がすべて書き込み可能か確認する
##
## 使い方:
##   sx_var_is_rw_all 名前1 [名前2 ...]
##
## 終了ステータス:
##    0  すべて書き込み可能 (SX_EX_OK)
##    1  読み取り専用が含まれる
##   64  変数名が無効 (SX_EX_USAGE)
sx_var_is_rw_all() {
	sx_var_is_name "${@}" || return "${SX_EX_USAGE}"

	__sx_var_is_rw_all "${@}" || return "${?}"
}

__sx_var_is_rw_all() {
	__sx_var_list_dep __sx_var_is_rw_all_ls_ "${@}"
	eval set -- "${__sx_var_is_rw_all_ls_}"
	unset __sx_var_is_rw_all_ls_

	__sx_var_is_rw "${@}" || return "${?}"
}

### sx_var_rw_chk - 指定された変数名（および配列要素）が書き込み可能か確認する
##
## 使い方:
##   sx_var_rw_chk 名前1 [名前2 ...]
##
## 説明:
##   指定された変数が有効な名前であり、かつすべて書き込み可能かを確認する。
##   読み取り専用が含まれる場合は SX_EX_NOPERM を返す。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  書き込み不可 (SX_EX_NOPERM)
sx_var_rw_chk() {
	sx_var_is_rw_all "${@}" || case "${?}" in
		1) return "${SX_EX_NOPERM}";;
		*) return "${?}";;
	esac
}
### sx_var_is_arr - 指定された変数がsx配列であるか確認する
##
## 使い方:
##   sx_var_is_arr 変数名1 [変数名2 ...]
##
## 終了ステータス:
##    0  すべてsx配列である (SX_EX_OK)
##    1  sx配列ではない変数が含まれる
##   64  変数名が無効 (SX_EX_USAGE)
sx_var_is_arr() {
	sx_var_is_name "${@}" || return "${SX_EX_USAGE}"

	__sx_var_is_arr "${@}" || return "${?}"
}

### __sx_var_is_arr - 指定された変数がsx配列であるか確認する（内部用）
##
## 使い方:
##   __sx_var_is_arr 変数名1 [変数名2 ...]
##
## 説明:
##   変数の値（シグネチャ）と長さ変数の妥当性をチェックする。
##   引数チェックは行わない。
__sx_var_is_arr() {
	for __sx_var_is_arr_arg_ in "${@}"; do
		if
			! eval sx_str_sw "\"\${${__sx_var_is_arr_arg_}-}\"" '"${SX_SIG_ARR}":' ||
			! eval sx_num_is_uint "\"\${${__sx_var_is_arr_arg_}_len-}\""
		then
			unset __sx_var_is_arr_arg_
			return 1
		fi
	done

	unset __sx_var_is_arr_arg_
}

### sx_var_list_dep - 指定された変数に関連するすべての変数名を取得する
##
## 使い方:
##   sx_var_list_dep 結果変数名 検索対象1 [検索対象2 ...]
##
## 説明:
##   指定された変数名、およびそれらがsx配列である場合に再帰的に含まれる
##   すべての変数名（_len, _0, _1...）をスペース区切りの文字列として取得し、
##   指定された結果変数に格納する。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
sx_var_list_dep() {
	sx_var_rw_chk "${1-}" || return "${?}"

	__sx_var_list_dep "${@}"
}

### __sx_var_list_dep - 指定された変数に関連するすべての変数名を取得する（内部用）
##
## 使い方:
##   __sx_var_list_dep 結果変数名 検索対象1 [検索対象2 ...]
##
## 説明:
##   位置パラメータをキューとして利用し、非再帰的に関連変数を収集する。
##   引数チェックは行わない。
__sx_var_list_dep() {
	__sx_var_list_dep_res_="${1}"
	shift

	__sx_var_list_dep_out_=' '

	while ! sx_str_eq "${#}" 0; do
		if sx_str_has "${__sx_var_list_dep_out_}" " ${1} "; then
			shift
			continue
		fi

		__sx_var_list_dep_out_="${__sx_var_list_dep_out_}${1} "

		if __sx_var_is_arr "${1}"; then
			eval "__sx_var_list_dep_len_=\"\${${1}_len}\""
			set -- "${@}" "${1}_len"

			__sx_var_list_dep_i_=0
			while ! sx_str_eq "${__sx_var_list_dep_i_}" "${__sx_var_list_dep_len_}"; do
				set -- "${@}" "${1}_${__sx_var_list_dep_i_}"
				__sx_var_list_dep_i_=$((__sx_var_list_dep_i_ + 1))
			done
		fi

		shift
	done

	__sx_var_list_dep_out_="${__sx_var_list_dep_out_# }"
	__sx_var_set "${__sx_var_list_dep_res_}=${__sx_var_list_dep_out_% }"

	unset __sx_var_list_dep_res_ __sx_var_list_dep_out_ __sx_var_list_dep_len_ __sx_var_list_dep_i_
}

### sx_var_unset - 変数または配列を関連要素を含めて削除する
##
## 使い方:
##   sx_var_unset 名前1 [名前2 ...]
##
## 説明:
##   指定された変数を削除する。対象がsx配列である場合は、その要素および
##   長さ変数も含めて再帰的にすべて削除する。
##   一つでも削除不可能な変数（読み取り専用など）が含まれる場合は、
##   どの変数も削除せずにエラーを返す。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  削除不可能な変数が含まれる (SX_EX_NOPERM)
sx_var_unset() {
	# リストの内容（変数名）がすべて書き込み可能か一括チェック
	sx_var_rw_chk "${@}" || return "${?}"

	__sx_var_unset "${@}"
}

### __sx_var_unset - 変数または配列を関連要素を含めて削除する（内部用）
##
## 使い方:
##   __sx_var_unset 名前1 [名前2 ...]
##
## 説明:
##   sx_var_unset の内部実装。
##   引数チェックは行わない。
__sx_var_unset() {
	while ! sx_str_eq "${#}" 0; do
		if __sx_var_is_arr "${1}"; then
			eval "__sx_var_unset_len_=\"\${${1}_len}\""
			set -- "${@}" "${1}_len"

			__sx_var_unset_i_=0
			while ! sx_str_eq "${__sx_var_unset_i_}" "${__sx_var_unset_len_}"; do
				set -- "${@}" "${1}_${__sx_var_unset_i_}"
				__sx_var_unset_i_=$((__sx_var_unset_i_ + 1))
			done
		fi

		unset -v "${1}"
		shift
	done

	unset __sx_var_unset_len_ __sx_var_unset_i_
}

### sx_var_set - 変数に値を設定、または削除する
##
## 使い方:
##   sx_var_set [名前=値 | 名前 ...]
##
## 説明:
##   指定された変数に値を設定する。= を含まない名前のみが指定された場合は、
##   その変数を削除（unset）する。対象が sx 配列である場合は、
##   関連するすべての要素（_len, _0, _1...）も再帰的に削除される。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  読み取り専用変数への操作失敗 (SX_EX_NOPERM)
sx_var_set() {
	__sx_var_set_chk=

	for __sx_var_set_arg in "${@}"; do
		__sx_var_set_chk="${__sx_var_set_arg%%=*}=${__sx_var_set_chk}"
	done

	sx_call_with_ifs = sx_var_rw_chk "${__sx_var_set_chk}" || {
		set -- "${?}"
		unset __sx_var_set_arg __sx_var_set_chk
		return "${1}"
	}

	unset __sx_var_set_arg __sx_var_set_chk
	__sx_var_set "${@}"
}

### __sx_var_set - 変数に値を設定、または削除する（内部用）
##
## 使い方:
##   __sx_var_set [名前=値 | 名前 ...]
##
## 説明:
##   sx_var_set の内部実装。
##   引数チェックは行わない。
__sx_var_set() {
	for __sx_var_set_arg_ in "${@}"; do
		__sx_var_set_vn_="${__sx_var_set_arg_%%=*}"
		__sx_var_unset "${__sx_var_set_vn_%%=*}"

		if ! sx_str_eq "${__sx_var_set_vn_}" "${__sx_var_set_arg_}"; then
			eval "${__sx_var_set_vn_}="'"${__sx_var_set_arg_#*=}"'
		fi
	done

	unset __sx_var_set_arg_ __sx_var_set_vn_
}

### sx_var_list_set - 設定されている変数の一覧を取得する
##
## 使い方:
##   sx_var_list_set 結果変数名
##
## 説明:
##   現在のシェルで設定されている全ての変数名（重複除去済み）をスペース区切りの文字列として取得し、
##   指定された結果変数に格納する。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
sx_var_list_set() {
	sx_var_rw_chk "${1-}" IFS || return "${?}"

	__sx_var_list_set "${@}"
}

### __sx_var_list_set - 設定されている変数の一覧を取得する（内部用）
##
## 使い方:
##   __sx_var_list_set 結果変数名
##
## 説明:
##   sx_var_list_set の内部実装。
##   引数チェックは行わない。
__sx_var_list_set() {
	__sx_var_list_set_set_="$(set)"
	__sx_var_list_set_res_="${1}"
	__sx_var_list_set_out_=' '

	IFS="${SX_CHAR_LF}" sx_util_eval '
		for __sx_var_list_set_ln_ in ${__sx_var_list_set_set_}; do
			__sx_var_list_set_vn_="${__sx_var_list_set_ln_%%=*}"

			if
				! sx_str_eq "${__sx_var_list_set_vn_}" "${__sx_var_list_set_ln_}" &&
				sx_var_is_set "${__sx_var_list_set_vn_}" &&
				! sx_str_has "${__sx_var_list_set_out_}" " ${__sx_var_list_set_vn_} "
			then
				__sx_var_list_set_out_="${__sx_var_list_set_out_}${__sx_var_list_set_vn_} "
			fi
		done
	'

	__sx_var_list_set_out_="${__sx_var_list_set_out_# }"
	__sx_var_set "${__sx_var_list_set_res_}=${__sx_var_list_set_out_% }"
	unset __sx_var_list_set_set_ __sx_var_list_set_res_ __sx_var_list_set_out_ __sx_var_list_set_ln_ __sx_var_list_set_vn_
}

### sx_var_list_ro - 読み取り専用変数の一覧を取得する
##
## 使い方:
##   sx_var_list_ro 結果変数名
##
## 説明:
##   現在のシェルで読み取り専用として設定されている全ての変数名（重複除去済み）を
##   スペース区切りの文字列として取得し、指定された結果変数に格納する。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
sx_var_list_ro() {
	sx_var_rw_chk "${1-}" IFS || return "${?}"

	__sx_var_list_ro "${@}"
}

### __sx_var_list_ro - 読み取り専用変数の一覧を取得する（内部用）
##
## 使い方:
##   __sx_var_list_ro 結果変数名
##
## 説明:
##   sx_var_list_ro の内部実装。
##   引数チェックは行わない。
__sx_var_list_ro() {
	__sx_var_list_ro_res_="${1}"
	__sx_var_list_ro_out_=' '

	IFS="${SX_CHAR_LF}" sx_util_eval '
		for __sx_var_list_ro_ln_ in $(readonly -p); do
			__sx_var_list_ro_vn_="${__sx_var_list_ro_ln_#readonly }"
			__sx_var_list_ro_vn_="${__sx_var_list_ro_vn_%%=*}"

			if
				! sx_str_eq "${__sx_var_list_ro_vn_}" "${__sx_var_list_ro_ln_}" &&
				sx_var_is_name "${__sx_var_list_ro_vn_}" &&
				sx_var_is_ro "${__sx_var_list_ro_vn_}" &&
				! sx_str_has "${__sx_var_list_ro_out_}" " ${__sx_var_list_ro_vn_} "
			then
				__sx_var_list_ro_out_="${__sx_var_list_ro_out_}${__sx_var_list_ro_vn_} "
			fi
		done
	'

	__sx_var_list_ro_out_="${__sx_var_list_ro_out_# }"
	__sx_var_set "${__sx_var_list_ro_res_}=${__sx_var_list_ro_out_% }"
	unset __sx_var_list_ro_res_ __sx_var_list_ro_out_ __sx_var_list_ro_ln_ __sx_var_list_ro_vn_
}

### sx_var_copy_is_rw - コピー先が構造を含めて書き込み可能か確認する
##
## 使い方:
##   sx_var_copy_is_rw [変数名1 [変数名2 [変数名3 ...]]]
##
## 説明:
##   与えられた変数名列に対して右方向の連鎖コピー（右シフト）を行った場合に、
##   書き込み対象となる全ての変数（配列の子要素を含む）が書き込み可能か確認する。
##   引数が 0 個または 1 個の場合は、書き込みが発生しないため成功する。
##
## 終了ステータス:
##    0  すべて書き込み可能 (SX_EX_OK)
##    1  書き込み不可が含まれる
##   64  引数不正 (SX_EX_USAGE)
sx_var_copy_is_rw() {
	sx_var_is_name "${@}" || return "${SX_EX_USAGE}"

	__sx_var_copy_is_rw "${@}" || return "${?}"
}

### __sx_var_copy_is_rw - コピー先が構造を含めて書き込み可能か確認する（内部用）
##
## 使い方:
##   __sx_var_copy_is_rw 変数名1 変数名2 [変数名3 ...]
##
## 説明:
##   sx_var_copy_is_rw の内部実装。
##   引数チェックは行わない。
__sx_var_copy_is_rw() {
	__sx_var_copyls __sx_var_copy_is_rw_ls_ "${@}"
	eval set -- "${__sx_var_copy_is_rw_ls_}"

	__sx_var_copy_is_rw_out_=
	for __sx_var_copy_is_rw_arg_ in "${@}"; do
		__sx_var_copy_is_rw_out_="${__sx_var_copy_is_rw_out_} ${__sx_var_copy_is_rw_arg_%%=*}"
	done

	eval set -- "${__sx_var_copy_is_rw_out_}"
	unset __sx_var_copy_is_rw_ls_ __sx_var_copy_is_rw_out_ __sx_var_copy_is_rw_arg_

	__sx_var_is_rw_all "${@}" || return "${?}"
}

### sx_var_copy - 変数の値を右方向に連鎖コピーする
##
## 使い方:
##   sx_var_copy [変数名1 [変数名2 [変数名3 ...]]]
##
## 説明:
##   与えられた変数名列に対して右方向の連鎖コピー（右シフト）を行う。
##   例: v1 v2 v3 の場合、v1 の値を v2 に、v2 の元の値を v3 にコピーする。
##   引数が 0 個または 1 個の場合は何もせず成功する。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  コピー先または関連要素が読み取り専用 (SX_EX_NOPERM)
sx_var_copy() {
	sx_var_is_name "${@}" || return "${SX_EX_USAGE}"

	sx_arg_quote __sx_var_copy_esc "${@}"
	__sx_var_copyls __sx_var_copy_ls "${@}"
	eval set -- "${__sx_var_copy_ls}"

	__sx_var_copy_ls=
	for __sx_var_copy_arg in "${@}"; do
		__sx_var_copy_ls="${__sx_var_copy_ls} ${__sx_var_copy_arg%%=*}"
	done

	eval set -- "${__sx_var_copy_esc}"
	eval sx_var_rw_chk "${__sx_var_copy_ls}" || return "${?}"

	unset __sx_var_copy_esc __sx_var_copy_ls __sx_var_copy_arg
	__sx_var_copy "${@}"
}

### __sx_var_copy - 変数の値を右方向に連鎖代入する（内部用）
##
## 使い方:
##   __sx_var_copy 変数名1 変数名2 [変数名3 ...]
##
## 説明:
##   与えられた変数名のリストに対して、右方向への連鎖コピー（右シフト）を行う。
##   例: v1 v2 v3 -> v2にv1の値を、v3にv2の元の値を代入する。
##
__sx_var_copy() {
	__sx_arg_quote __sx_var_copy_esc_ "${@}"
	__sx_var_copyls __sx_var_copy_ls_ "${@}"
	eval set -- "${__sx_var_copy_ls_}"

	# 1. 値のキャプチャと代入式の生成
	__sx_var_copy_asg_=

	for __sx_var_copy_pair_ in "${@}"; do
		__sx_var_copy_dest_="${__sx_var_copy_pair_%%=*}"
		__sx_var_copy_src_="${__sx_var_copy_pair_#*=}"

		if __sx_var_is_set "${__sx_var_copy_src_}"; then
			eval __sx_arg_quote __sx_var_copy_qval_ "\"\${${__sx_var_copy_src_}}\""
			__sx_var_copy_asg_="${__sx_var_copy_asg_} ${__sx_var_copy_dest_}=${__sx_var_copy_qval_}"
		else
			__sx_var_copy_asg_="${__sx_var_copy_asg_} ${__sx_var_copy_dest_}"
		fi
	done

	# 2. 最初の引数以外を削除
	eval set -- "${__sx_var_copy_esc_}"
	shift "$((0 < $#))"

	sx_var_unset "${@}"

	# 3. 代入の実行
	eval __sx_var_set "${__sx_var_copy_asg_}"

	# 内部用変数を掃除
	unset __sx_var_copy_esc_ __sx_var_copy_ls_ __sx_var_copy_asg_ __sx_var_copy_pair_ __sx_var_copy_dest_ __sx_var_copy_src_ __sx_var_copy_qval_
}

### sx_var_move - 変数を右方向に連鎖移動する
##
## 使い方:
##   sx_var_move [変数名1 [変数名2 [変数名3 ...]]]
##
## 説明:
##   与えられた変数名列に対して右方向の連鎖移動を行う。
##   例: v1 v2 v3 の場合、v1 の値を v2 に、v2 の元の値を v3 に移し、最後に v1 を削除する。
##   引数が 0 個の場合は何もせず成功する。
##   引数が 1 個の場合は、その変数を削除する。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  移動先または削除対象が読み取り専用 (SX_EX_NOPERM)
sx_var_move() {
	sx_var_rw_chk ${1+"${1}"} || return "${?}"

	sx_var_copy "${@}" || return "${?}"
	__sx_var_unset ${1+"${1}"}
}

### __sx_var_move - 変数を右方向に連鎖移動する（内部用）
##
## 使い方:
##   __sx_var_move 変数名1 変数名2 [変数名3 ...]
##
## 説明:
##   与えられた変数名のリストに対して、右方向への連鎖移動を行う。
##   例: v1 v2 v3 -> v1の値をv2に、v2の元の値をv3に代入し、最後にv1を消去する。
##   この関数は sx_var_move から呼び出されることを前提としており、
##   引数はIFSで分割済みの位置パラメータとして受け取る。
__sx_var_move() {
	__sx_var_copy "${@}"
	__sx_var_unset ${1+"${1}"}
}

### sx_var_swap - 変数を右方向にローテーションする
##
## 使い方:
##   sx_var_swap [変数1 [変数2 [変数3 ...]]]
##
## 挙動:
## - 指定された変数群に対して右方向のローテーションを行う
## - 例: v1 v2 v3 の場合、v3 の値を v1 に、v1 の値を v2 に、v2 の値を v3 に移動する
## - 引数が 0 個の場合は何もせず成功する
## - 引数が 1 個の場合も実質的に何も変化せず成功する
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  変数が読み取り専用 (SX_EX_NOPERM)
sx_var_swap() {
	! sx_str_eq "${#}" 0 || return "${SX_EX_OK}"

	eval sx_var_copy "\"\${${#}}\"" __sx_var_swap_last || return "${?}"

	sx_var_move "${@}" || {
		set -- "${?}"
		__sx_var_unset __sx_var_swap_last
		return "${1}"
	}

	__sx_var_copy __sx_var_swap_last "${1}"
	__sx_var_unset __sx_var_swap_last
}

### __sx_var_swap - 変数を右方向にローテーションする（内部用）
##
## 使い方:
##   __sx_var_swap 変数名1 変数名2 [変数名3 ...]
##
## 説明:
##   与えられた変数名のリストに対して、右方向へのローテーションを行う。
##   例: v1 v2 v3 -> v1の値をv2に、v2の値をv3に、v3の元の値をv1に代入する。
##   この関数は sx_var_swap から呼び出されることを前提としており、
##   引数はIFSで分割済みの位置パラメータとして受け取る。
__sx_var_swap() {
	! sx_str_eq "${#}" 0 || return "${SX_EX_OK}"

	eval __sx_var_copy "\"\${${#}}\"" __sx_var_swap_last_
	__sx_var_move "${@}"
	__sx_var_copy __sx_var_swap_last_ "${1}"

	__sx_var_unset __sx_var_swap_last_
}

### sx_str_eq - すべての引数が文字列として一致するか確認する
##
## 使い方:
##   sx_str_eq [文字列1 [文字列2 ...]]
##
## 終了ステータス:
##    0  すべて一致する (または引数が1つ以下)
##    1  一致しない文字列が含まれる
sx_str_eq() {
	__sx_str_eq_first="${1-}"
	shift "$((0 < $#))"

	for __sx_str_eq_arg in "${@}"; do
		case "${__sx_str_eq_arg}" in
			"${__sx_str_eq_first}") ;;
			*)
				unset __sx_str_eq_first __sx_str_eq_arg
				return 1
				;;
		esac
	done

	unset __sx_str_eq_first __sx_str_eq_arg
}

### sx_str_any - 第一引数が、後続引数のいずれかの文字列と完全に一致するか確認する
##
## 使い方:
##   sx_str_any [比較元文字列 [比較対象1 [比較対象2 ...]]]
##
## 挙動:
## - 第一引数を比較元文字列として扱う
## - 第二引数以降を比較対象文字列として順に比較する
## - 比較対象文字列が 1 つもない場合は不一致として 1 を返す
## - 引数が 0 個の場合は、比較元文字列を空文字列として扱い、やはり 1 を返す
##
## 終了ステータス:
##    0  いずれかと一致する (SX_EX_OK)
##    1  一つも一致しない
sx_str_any() {
	__sx_str_any_tgt="${1-}"
	shift "$((0 < $#))"

	for __sx_str_any_arg in "${@}"; do
		if sx_str_eq "${__sx_str_any_tgt}" "${__sx_str_any_arg}"; then
			unset __sx_str_any_tgt __sx_str_any_arg
			return "${SX_EX_OK}"
		fi
	done

	unset __sx_str_any_tgt __sx_str_any_arg
	return 1
}

### sx_str_has - 第一引数に、第二引数以降のいずれかの文字列が含まれているか確認する
##
## 使い方:
##   sx_str_has [検索対象文字列 [含まれるべき文字列1 [含まれるべき文字列2 ...]]]
##
## 挙動:
## - 検索対象文字列が省略された場合は空文字列とみなす
## - 含まれるべき文字列は 0 個以上指定できる
## - 第二引数以降のいずれかが検索対象文字列に含まれていれば成功する
## - 含まれるべき文字列が 1 つも指定されなかった場合は失敗する
## - 含まれるべき文字列に空文字列が含まれる場合は常に成功する
##
## 終了ステータス:
##    0  いずれかが含まれている (SX_EX_OK)
##    1  一致する文字列がない
sx_str_has() {
	__sx_str_has_tgt="${1-}"
	shift "$((0 < $#))"

	for __sx_str_has_arg in "${@}"; do
		case "${__sx_str_has_tgt}" in
			*"${__sx_str_has_arg}"*)
				unset __sx_str_has_tgt __sx_str_has_arg
				return "${SX_EX_OK}"
				;;
		esac
	done

	unset __sx_str_has_tgt __sx_str_has_arg
	return 1
}

### sx_str_match - 第一引数が、後続引数のいずれかのパターンにマッチするか確認する
##
## 使い方:
##   sx_str_match [検索対象文字列 [パターン1 [パターン2 ...]]]
##
## 挙動:
## - 検索対象文字列が省略された場合は空文字列とみなす
## - パターンはシェル標準の glob 形式（*, ?, [...]）を使用できる
## - 第二引数以降のいずれかが検索対象文字列にマッチすれば成功する
## - パターンが 1 つも指定されなかった場合は失敗する
##
## 終了ステータス:
##    0  いずれかのパターンにマッチする (SX_EX_OK)
##    1  マッチするパターンがない
sx_str_match() {
	__sx_str_match_tgt="${1-}"
	shift "$((0 < $#))"

	for __sx_str_match_arg in "${@}"; do
		case "${__sx_str_match_tgt}" in
			${__sx_str_match_arg})
				unset __sx_str_match_tgt __sx_str_match_arg
				return "${SX_EX_OK}"
				;;
		esac
	done

	unset __sx_str_match_tgt __sx_str_match_arg
	return 1
}

### sx_str_sw - 第一引数が、第二引数以降のいずれかの文字列で始まっているか確認する
##
## 使い方:
##   sx_str_sw [検索対象文字列 [開始文字列1 [開始文字列2 ...]]]
##
## 挙動:
## - 検索対象文字列が省略された場合は空文字列とみなす
## - 開始文字列は 0 個以上指定できる
## - 第二引数以降のいずれかが検索対象文字列の接頭辞であれば成功する
## - 開始文字列が 1 つも指定されなかった場合は失敗する
## - 開始文字列に空文字列が含まれる場合は常に成功する
##
## 終了ステータス:
##    0  いずれかの開始文字列で始まっている (SX_EX_OK)
##    1  一致する開始文字列がない
sx_str_sw() {
	__sx_str_sw_tgt="${1-}"
	shift "$((0 < $#))"

	for __sx_str_sw_arg in "${@}"; do
		case "${__sx_str_sw_tgt}" in
			"${__sx_str_sw_arg}"*)
				unset __sx_str_sw_tgt __sx_str_sw_arg
				return "${SX_EX_OK}"
				;;
		esac
	done

	unset __sx_str_sw_tgt __sx_str_sw_arg
	return 1
}

### sx_str_ew - 第一引数が、第二引数以降のいずれかの文字列で終わっているか確認する
##
## 使い方:
##   sx_str_ew [検索対象文字列 [終了文字列1 [終了文字列2 ...]]]
##
## 挙動:
## - 検索対象文字列が省略された場合は空文字列とみなす
## - 終了文字列は 0 個以上指定できる
## - 第二引数以降のいずれかが検索対象文字列の接尾辞であれば成功する
## - 終了文字列が 1 つも指定されなかった場合は失敗する
## - 終了文字列に空文字列が含まれる場合は常に成功する
##
## 終了ステータス:
##    0  いずれかの終了文字列で終わっている (SX_EX_OK)
##    1  一致する終了文字列がない
sx_str_ew() {
	__sx_str_ew_tgt="${1-}"
	shift "$((0 < $#))"

	for __sx_str_ew_arg in "${@}"; do
		case "${__sx_str_ew_tgt}" in
			*"${__sx_str_ew_arg}")
				unset __sx_str_ew_tgt __sx_str_ew_arg
				return "${SX_EX_OK}"
				;;
		esac
	done

	unset __sx_str_ew_tgt __sx_str_ew_arg
	return 1
}

### sx_str_sub - 文字列内のパターンを置換する
##
## 使い方:
##   sx_str_sub 結果変数名 [元文字列 [検索パターン [置換文字列 [回数制限 [方向(f/b)]]]]]
##
## 説明:
##   元文字列の中に含まれる検索パターンを、置換文字列に置き換えて結果変数に格納する。
##   省略された引数は、元文字列・検索パターン・置換文字列が空文字列、
##   回数制限が 2147483647、方向が 'f' として扱われる。
##   検索パターンが空文字列の場合は置換を行わず、元文字列をそのまま格納する。
##   回数制限を指定すると、その回数分だけ置換を行う。
##   方向を 'f' (Forward) にすると前方から、'b' (Backward) にすると後方から置換する。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
sx_str_sub() {
	sx_var_rw_chk "${1-}" || return "${?}"

	{ sx_num_is_uint "${5-0}" && sx_str_any "${6-f}" f b; } || return "${SX_EX_USAGE}"

	__sx_str_sub "${@}"
}

### __sx_str_sub - 文字列内のパターンを置換する（内部用）
##
## 使い方:
##   __sx_str_sub 結果変数名 [元文字列 [検索パターン [置換文字列 [回数制限 [方向(f/b)]]]]]
##
## 説明:
##   sx_str_sub の内部実装。
##   引数チェックは行わない。
__sx_str_sub() {
	set -- "${1}" "${2-}" "${3-}" "${4-}" "${5-2147483647}" "${6-f}"
	__sx_str_sub_res_="${1}"
	__sx_str_sub_str_="${2}"
	__sx_str_sub_pat_="${3}"
	__sx_str_sub_rep_="${4}"
	__sx_str_sub_lim_="${5}"
	__sx_str_sub_dir_="${6}"

	# パターンが空の場合は、元の文字列をそのまま結果変数に格納して終了
	if sx_str_eq "${__sx_str_sub_pat_}" ''; then
		__sx_var_set "${__sx_str_sub_res_}=${__sx_str_sub_str_}"
		unset __sx_str_sub_res_ __sx_str_sub_str_ __sx_str_sub_pat_ __sx_str_sub_rep_ __sx_str_sub_lim_ __sx_str_sub_dir_
		return 0
	fi

	__sx_str_sub_out_=
	__sx_str_sub_i_=0

	if sx_str_eq "${__sx_str_sub_dir_}" b; then
		# 後ろ向き置換 (Backward)
		while
			sx_str_has "${__sx_str_sub_str_}" "${__sx_str_sub_pat_}" &&
			sx_num_is_lt "${__sx_str_sub_i_}" "${__sx_str_sub_lim_}"
		do
			# 「置換文字」＋「後ろの部分」＋「これまでの蓄積」を結合
			__sx_str_sub_out_="${__sx_str_sub_rep_}${__sx_str_sub_str_##*"${__sx_str_sub_pat_}"}${__sx_str_sub_out_}"
			# 残りの文字列を更新（右端のパターンより前を残す）
			__sx_str_sub_str_="${__sx_str_sub_str_%"${__sx_str_sub_pat_}"*}"
			__sx_str_sub_i_=$((__sx_str_sub_i_ + 1))
		done
		# 最後に残った左側の部分を結合
		__sx_str_sub_out_="${__sx_str_sub_str_}${__sx_str_sub_out_}"
	else
		# 前向き置換 (Forward)
		while
			sx_str_has "${__sx_str_sub_str_}" "${__sx_str_sub_pat_}" &&
			sx_num_is_lt "${__sx_str_sub_i_}" "${__sx_str_sub_lim_}"
		do
			__sx_str_sub_out_="${__sx_str_sub_out_}${__sx_str_sub_str_%%"${__sx_str_sub_pat_}"*}${__sx_str_sub_rep_}"
			__sx_str_sub_str_="${__sx_str_sub_str_#*"${__sx_str_sub_pat_}"}"
			__sx_str_sub_i_=$((__sx_str_sub_i_ + 1))
		done
		__sx_str_sub_out_="${__sx_str_sub_out_}${__sx_str_sub_str_}"
	fi

	# 安全に代入 (eval 内で値を展開せず、変数の参照として渡す)
	__sx_var_set "${__sx_str_sub_res_}=${__sx_str_sub_out_}"

	# 内部変数のクリーニング
	unset __sx_str_sub_res_ __sx_str_sub_str_ __sx_str_sub_pat_ __sx_str_sub_rep_ __sx_str_sub_lim_ __sx_str_sub_dir_ __sx_str_sub_out_ __sx_str_sub_i_
}

### sx_str_rep - 文字列を繰り返す
##
## 使い方:
##   sx_str_rep 結果変数名 [元文字列 [繰り返し回数]]
##
## 説明:
##   元文字列を指定された回数だけ繰り返して、結果変数に格納する。
##   省略された引数は、元文字列が空文字列、繰り返し回数が 1 として扱われる。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
sx_str_rep() {
	sx_var_rw_chk "${1-}" || return "${?}"

	sx_num_is_uint "${3-1}" || return "${SX_EX_USAGE}"

	__sx_str_rep "${@}"
}

### __sx_str_rep - 文字列を繰り返す（内部用）
##
## 使い方:
##   __sx_str_rep 結果変数名 [元文字列 [繰り返し回数]]
##
## 説明:
##   sx_str_rep の内部実装。
##   引数チェックは行わない。
__sx_str_rep() {
	set -- "${1}" "${2-}" "${3-1}"
	__sx_str_rep_out_=

	while ! sx_str_eq "${3}" 0; do
		if sx_str_eq "$((${3} % 2))" 1; then
			__sx_str_rep_out_="${__sx_str_rep_out_}${2}"
		fi

		set -- "${1}" "${2}${2}" "$((${3} / 2))"
	done

	__sx_var_set "${1}=${__sx_str_rep_out_}"

	unset __sx_str_rep_out_
}

### sx_uuid_is_uuid - すべての引数が UUID 形式であるか確認する
##
## 使い方:
##   sx_uuid_is_uuid [文字列1 [文字列2 ...]]
##
## 説明:
##   引数で指定されたすべての文字列が、標準的な UUID 形式（8-4-4-4-12 の 16 進数）
##   であるかを確認する。大文字と小文字は区別しない。
##
## 終了ステータス:
##    0  すべて UUID 形式である (SX_EX_OK)
##    1  UUID 形式ではない文字列が含まれる
sx_uuid_is_uuid() {
	for __sx_uuid_is_uuid_arg in "${@}"; do
		case "${__sx_uuid_is_uuid_arg}" in
			[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]-[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]-[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]-[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]-[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]) ;;
			*)
				unset __sx_uuid_is_uuid_arg
				return 1
				;;
		esac
	done

	unset __sx_uuid_is_uuid_arg
}

### sx_num_is_digit - すべての引数が数字のみで構成されている（空でない）か確認する
##
## 使い方:
##   sx_num_is_digit [文字列1 [文字列2 ...]]
##
## 終了ステータス:
##    0  すべて数字のみで構成されている (SX_EX_OK)
##    1  数字以外が含まれる、または空文字列が含まれる
sx_num_is_digit() {
	for __sx_num_is_digit_arg in "${@}"; do
		case "${__sx_num_is_digit_arg}" in
			'' | *[!0-9]*)
				unset __sx_num_is_digit_arg
				return 1
				;;
		esac
	done

	unset __sx_num_is_digit_arg
}

### sx_num_is_uint - すべての引数が符号無しの整数（0 または正の整数）であるか確認する
##
## 使い方:
##   sx_num_is_uint [文字列1 [文字列2 ...]]
##
## 終了ステータス:
##    0  すべて符号無しの整数である (SX_EX_OK)
##    1  符号無しの整数ではない値が含まれる
sx_num_is_uint() {
	sx_num_is_digit "${@}" || return 1

	for __sx_num_is_uint_arg in "${@}"; do
		case "${__sx_num_is_uint_arg}" in
			0?*)
				unset __sx_num_is_uint_arg
				return 1
				;;
		esac
	done

	unset __sx_num_is_uint_arg
}

### sx_num_is_pint - すべての引数が正の整数（1 以上の整数）であるか確認する
##
## 使い方:
##   sx_num_is_pint [文字列1 [文字列2 ...]]
##
## 終了ステータス:
##    0  すべて正の整数である (SX_EX_OK)
##    1  正の整数ではない値が含まれる
sx_num_is_pint() {
	sx_num_is_digit "${@}" || return 1

	for __sx_num_is_pint_arg in "${@}"; do
		case "${__sx_num_is_pint_arg}" in
			0*)
				unset __sx_num_is_pint_arg
				return 1
				;;
		esac
	done

	unset __sx_num_is_pint_arg
}

### sx_num_is_le - 引数が昇順（等号を含む）に並んでいるか確認する
##
## 使い方:
##   sx_num_is_le [数値1 [数値2 ...]]
##
## 終了ステータス:
##    0  数値1 <= 数値2 <= ... である (SX_EX_OK)
##    1  条件を満たさない、または数値でない引数が含まれる
sx_num_is_le() {
	while sx_str_eq "${2+X}" X; do
		if { sx_str_eq "$((${1} <= ${2}))" 0; } 2>/dev/null; then
			return 1
		fi

		shift
	done
}

### sx_num_is_lt - 引数が厳密な昇順に並んでいるか確認する
##
## 使い方:
##   sx_num_is_lt [数値1 [数値2 ...]]
##
## 終了ステータス:
##    0  数値1 < 数値2 < ... である (SX_EX_OK)
##    1  条件を満たさない、または数値でない引数が含まれる
sx_num_is_lt() {
	while sx_str_eq "${2+X}" X; do
		if { sx_str_eq "$((${1} < ${2}))" 0; } 2>/dev/null; then
			return 1
		fi

		shift
	done
}

### sx_arr_is_rw - 配列の指定範囲が書き込み可能か確認する
##
## 使い方:
##   sx_arr_is_rw 配列名 [[開始インデックス [個数]] ...]
##
## 説明:
##   指定された名前に対応する配列要素範囲および長さ保持変数 (${配列名}_len) が
##   書き込み可能か確認する。
##   実体が sx 配列でない場合でも確認自体は可能で、その場合は指定された範囲の変数名と
##   ${配列名}_len の書き込み可否を検査する。
##   引数なしの場合: 配列名と ${配列名}_len に加え、sx 配列であれば 0 から末尾までの全要素を確認する。
##   個数が省略された場合: sx 配列であれば開始インデックスから末尾までを確認し、
##   sx 配列でなければその開始インデックス単体を確認する。
##
## 終了ステータス:
##    0  すべて書き込み可能 (SX_EX_OK)
##    1  書き込み不可が含まれる
##   64  引数不正 (SX_EX_USAGE)
sx_arr_is_rw() {
	sx_var_is_name "${1-}" || return "${SX_EX_USAGE}"

	__sx_arr_is_rw_name="${1}"
	shift

	if ! sx_num_is_uint "${@}"; then
		unset __sx_arr_is_rw_name
		return "${SX_EX_USAGE}"
	fi

	set -- "${__sx_arr_is_rw_name}" "${@}"
	unset __sx_arr_is_rw_name

	__sx_arr_is_rw "${@}" || return "${?}"
}

### __sx_arr_is_rw - 配列の指定範囲が書き込み可能か確認する（内部用）
##
## 使い方:
##   __sx_arr_is_rw 配列名 [開始インデックス [個数]]
##
## 説明:
##   sx_arr_is_rw の内部実装。
##   引数チェックは行わない。
__sx_arr_is_rw() {
	__sx_var_is_rw "${1}" "${1}_len" || return 1
	__sx_arr_is_rw_name_="${1}"
	__sx_arr_is_rw_chk_=
	shift

	! sx_str_eq "${#}" 0 || set -- 0

	if sx_str_eq "$((${#} % 2))" 0; then
		:
	elif sx_var_is_arr "${__sx_arr_is_rw_name_}"; then
		# 個数が省略された場合は末尾まで
		eval set -- '"${@}"' "\$((${__sx_arr_is_rw_name_}_len - \${${#}}))"
	else
		set -- "${@}" 0
	fi

	while ! sx_str_eq "${#}" 0; do
		eval 'shift 2;' set -- "${1}" "$((${1} + ${2}))" '"${@}"'

		while sx_num_is_lt "${1}" "${2}"; do
			__sx_arr_is_rw_chk_="${__sx_arr_is_rw_chk_}${__sx_arr_is_rw_name_}_${1} "
			eval 'shift 2;' set -- "$((${1} + 1))" "${2}" '"${@}"'
		done

		shift 2
	done

	eval set -- "${__sx_arr_is_rw_chk_}"
	unset __sx_arr_is_rw_name_ __sx_arr_is_rw_chk_

	sx_var_is_rw_all "${@}" || return "${?}"
}

### sx_str_split - 文字列を分割して配列に格納する
##
## 使い方:
##   sx_str_split 配列名 [文字列 [区切り文字 [分割回数 [方向(f/b)]]]]
##
## 説明:
##   指定された文字列を区切り文字で分割し、sxライブラリ形式の配列として格納する。
##   分割回数（limit）が指定された場合、最大でその回数分だけ分割を行う。
##   方向を 'f' (Forward) にすると前方から、'b' (Backward) にすると後方から分割する。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  変数が読み取り専用 (SX_EX_NOPERM)
sx_str_split() {
	{ sx_num_is_uint "${4-0}" && sx_str_any "${5-f}" f b; } || return "${SX_EX_USAGE}"

	__sx_str_split_arr="${1-}"
	shift

	__sx_str_split __sx_str_split_tmp "${@}"
	sx_var_copy __sx_str_split_tmp "${__sx_str_split_arr}" || {
		set -- "${?}"
		unset __sx_str_split_arr
		__sx_var_unset __sx_str_split_tmp
		return "${1}"
	}

	unset __sx_str_split_arr
	__sx_var_unset __sx_str_split_tmp
}

### __sx_str_split - 文字列を分割して配列に格納する（内部用）
##
## 使い方:
##   __sx_str_split 配列名 [文字列 [区切り文字 [分割回数 [方向(f/b)]]]]
##
## 説明:
##   指定された文字列を区切り文字で分割し、sxライブラリ形式の配列として格納する。
##   分割回数（limit）が指定された場合、最大でその回数分だけ分割を行う。
##   方向が 'f' (Forward) の場合は前方から、'b' (Backward) の場合は後方から分割する。
##   この関数は引数の検証や書き込み権限のチェックを行わない。
__sx_str_split() {
	__sx_str_split_arr_="${1}"
	__sx_str_split_str_="${2-}"
	__sx_str_split_sep_="${3-}"
	__sx_str_split_lim_="${4-2147483647}"
	__sx_str_split_dir_="${5-f}"
	__sx_str_split_i_=0
	__sx_str_split_out_=

	if sx_str_eq "${__sx_str_split_sep_}" ''; then
		__sx_arr_gen "${__sx_str_split_arr_}" "${__sx_str_split_str_}"
		unset __sx_str_split_arr_ __sx_str_split_str_ __sx_str_split_sep_ __sx_str_split_lim_ __sx_str_split_dir_ __sx_str_split_i_ __sx_str_split_out_
		return "${SX_EX_OK}"
	fi

	if sx_str_eq "${__sx_str_split_dir_}" b; then
		while
			sx_str_has "${__sx_str_split_str_}" "${__sx_str_split_sep_}" &&
			sx_num_is_lt "${__sx_str_split_i_}" "${__sx_str_split_lim_}"
		do
			__sx_arg_quote __sx_str_split_esc_ "${__sx_str_split_str_##*"${__sx_str_split_sep_}"}"
			__sx_str_split_out_="${__sx_str_split_esc_} ${__sx_str_split_out_}"
			__sx_str_split_str_="${__sx_str_split_str_%"${__sx_str_split_sep_}"*}"
			__sx_str_split_i_=$((__sx_str_split_i_ + 1))
		done

		__sx_arg_quote __sx_str_split_esc_ "${__sx_str_split_str_}"
		__sx_str_split_out_="${__sx_str_split_esc_} ${__sx_str_split_out_}"
	else
		while
			sx_str_has "${__sx_str_split_str_}" "${__sx_str_split_sep_}" &&
			sx_num_is_lt "${__sx_str_split_i_}" "${__sx_str_split_lim_}"
		do
			__sx_arg_quote __sx_str_split_esc_ "${__sx_str_split_str_%%"${__sx_str_split_sep_}"*}"
			__sx_str_split_out_="${__sx_str_split_out_} ${__sx_str_split_esc_}"
			__sx_str_split_str_="${__sx_str_split_str_#*"${__sx_str_split_sep_}"}"
			__sx_str_split_i_=$((__sx_str_split_i_ + 1))
		done

		__sx_arg_quote __sx_str_split_esc_ "${__sx_str_split_str_}"
		__sx_str_split_out_="${__sx_str_split_out_} ${__sx_str_split_esc_}"
	fi

	# 一括で配列を生成
	eval __sx_arr_gen "${__sx_str_split_arr_}" "${__sx_str_split_out_}"

	unset __sx_str_split_arr_ __sx_str_split_str_ __sx_str_split_sep_ __sx_str_split_lim_ __sx_str_split_dir_ __sx_str_split_i_ __sx_str_split_out_ __sx_str_split_esc_
}

### sx_arr_gen - 配列を初期化し、要素を追加する
##
## 使い方:
##   sx_arr_gen 配列名 [値 ...]
##
## 説明:
##   指定された配列を新規に作成（または既存の配列を削除して再作成）し、
##   引数で指定された値を要素として追加する。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  変数が読み取り専用 (SX_EX_NOPERM)
sx_arr_gen() {
	sx_var_is_name "${1-}" || return "${SX_EX_USAGE}"
	sx_arr_is_rw "${1}" 0 "$((${#} - 1))" || return "${SX_EX_NOPERM}"

	__sx_arr_gen "${@}"
}

### __sx_arr_gen - 配列を初期化し、要素を追加する（内部用）
##
## 使い方:
##   __sx_arr_gen 配列名 [値 ...]
##
## 説明:
##   指定された配列を新規に作成し、引数で指定された値を要素として追加する。
##   この関数は引数の検証や書き込み権限のチェックを行わない。
__sx_arr_gen() {
	__sx_var_set "${1}=${SX_SIG_ARR}:" "${1}_len=0"
	__sx_arr_push "${@}"
}

### sx_arr_push - 配列の末尾に要素を追加する
##
## 使い方:
##   sx_arr_push 配列名 [値 ...]
##
## 説明:
##   指定された sx 配列の末尾に 0 個以上の値を追加する。
##   配列名が有効でも、対象が sx 配列でない場合は SX_EX_DATAERR を返す。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  配列名が無効 (SX_EX_USAGE)
##   65  対象が sx 配列ではない (SX_EX_DATAERR)
##   77  変数が読み取り専用 (SX_EX_NOPERM)
sx_arr_push() {
	sx_var_is_name "${1-}" || return "${SX_EX_USAGE}"
	__sx_var_is_arr "${1}" || return "${SX_EX_DATAERR}"
	eval sx_arr_is_rw "${1}" "\"\${${1}_len}\"" "$((${#} - 1))" || return "${SX_EX_NOPERM}"

	__sx_arr_push "${@}"
}

### __sx_arr_push - 配列の末尾に要素を追加する（内部用）
##
## 使い方:
##   __sx_arr_push 配列名 [値 ...]
##
## 説明:
##   指定された配列の末尾に一つ以上の値を追加し、長さを更新する。
##   この関数は引数の検証や書き込み権限のチェックを行わない。
__sx_arr_push() {
	eval "__sx_arr_push_i_=\"\${${1}_len}\""

	__sx_arr_push_arr_="${1}"
	shift

	# 値の追加
	for __sx_arr_push_arg_ in "${@}"; do
		eval "${__sx_arr_push_arr_}_${__sx_arr_push_i_}=\"\${__sx_arr_push_arg_}\""
		__sx_arr_push_i_="$((__sx_arr_push_i_ + 1))"
	done

	# 長さを更新
	eval "${__sx_arr_push_arr_}_len=${__sx_arr_push_i_}"
	__sx_var_touch "${__sx_arr_push_arr_}"

	unset __sx_arr_push_i_ __sx_arr_push_arr_ __sx_arr_push_arg_
}

### sx_arr_pop - 配列の末尾から要素を取り出す
##
## 使い方:
##   sx_arr_pop 配列名 [結果変数名1 [結果変数名2 ...]]
##
## 説明:
##   指定された sx 配列の末尾から要素を取り出し、結果変数に格納する。
##   結果変数名が複数指定された場合は、指定された順に末尾から順次ポップする。
##   結果変数名が省略された場合は、1 つの要素をポップして破棄する。
##   - が結果変数名として指定された場合は、その要素をポップするが値は格納しない。
##   配列名が結果変数名に含まれている場合はエラーを返す。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##    1  配列が空、または要素数が不足している
##   64  配列名が無効、または結果変数名と重複している (SX_EX_USAGE)
##   65  対象が sx 配列ではない (SX_EX_DATAERR)
##   77  変数が読み取り専用 (SX_EX_NOPERM)
sx_arr_pop() {
	sx_var_is_arr "${1-}" || case "${?}" in
		1) return "${SX_EX_DATAERR}";;
		*) return "${?}";;
	esac

	__sx_arr_pop_arr="${1}"
	eval "__sx_arr_pop_len=\"\${${1}_len}\""
	shift

	! sx_str_eq "${#}" 0 || set -- -
	__sx_arg_norm __sx_arr_pop_args - "${@}"
	eval set -- "${__sx_arr_pop_args}"
	unset __sx_arr_pop_args

	# 要素数チェック
	sx_num_is_le "${#}" "${__sx_arr_pop_len}" || {
		unset __sx_arr_pop_arr __sx_arr_pop_len
		return 1
	}

	# 配列の書き込み権限チェック
	sx_arr_is_rw "${__sx_arr_pop_arr}" "$((__sx_arr_pop_len - ${#}))" "${#}" || {
		case "${?}" in
			1) set -- "${SX_EX_NOPERM}";;
			*) set -- "${?}";;
		esac

		unset __sx_arr_pop_arr __sx_arr_pop_len
		return "${1}"
	}

	__sx_arr_pop_i="${__sx_arr_pop_len}"
	for __sx_arr_pop_dest in "${@}"; do
		__sx_arr_pop_i=$((__sx_arr_pop_i - 1))

		! sx_str_eq "${__sx_arr_pop_dest}" - || continue

		# pop中に配列以下の更新を禁止
		if sx_str_match "${__sx_arr_pop_dest}" "${__sx_arr_pop_arr}" "${__sx_arr_pop_arr}_*"; then
			unset __sx_arr_pop_arr __sx_arr_pop_len __sx_arr_pop_i __sx_arr_pop_dest
			return "${SX_EX_USAGE}"
		fi

		sx_var_copy_is_rw "${__sx_arr_pop_arr}_${__sx_arr_pop_i}" "${__sx_arr_pop_dest}" || {
			case "${?}" in
				1) set -- "${SX_EX_NOPERM}";;
				*) set -- "${?}";;
			esac

			unset __sx_arr_pop_arr __sx_arr_pop_len __sx_arr_pop_i __sx_arr_pop_dest
			return "${1}"
		}
	done

	set -- "${__sx_arr_pop_arr}" "${@}"
	unset __sx_arr_pop_arr __sx_arr_pop_len __sx_arr_pop_i __sx_arr_pop_dest
	__sx_arr_pop0 "${@}" || return "${?}"
}

### __sx_arr_pop - 配列の末尾から要素を取り出す（内部用）
##
## 使い方:
##   __sx_arr_pop 配列名 [結果変数名1 ...]
##
## 説明:
##   指定された配列の末尾から要素を取り出し、結果変数に格納する。
##   この関数は引数の検証や書き込み権限のチェックを行わない。
__sx_arr_pop() {
	! sx_str_eq "${#}" 1 || set -- -
	__sx_arg_norm __sx_arr_pop_args_ - "${@}"
	eval set -- "${__sx_arr_pop_args_}"
	unset __sx_arr_pop_args_

	__sx_arr_pop0 "${@}" || return "${?}"
}

__sx_arr_pop0() {
	__sx_arr_pop0_arr_="${1}"
	eval "__sx_arr_pop0_len_=\"\${${1}_len}\""
	shift

	sx_num_is_le "${#}" "${__sx_arr_pop0_len_}" || {
		unset __sx_arr_pop0_arr_ __sx_arr_pop0_len_
		return 1
	}

	for __sx_arr_pop0_dest_ in "${@}"; do
		__sx_arr_pop0_len_=$((__sx_arr_pop0_len_ - 1))
		__sx_arr_pop0_src_="${__sx_arr_pop0_arr_}_${__sx_arr_pop0_len_}"

		if ! sx_str_eq "${__sx_arr_pop0_dest_}" -; then
			__sx_var_copy "${__sx_arr_pop0_src_}" "${__sx_arr_pop0_dest_}"
		fi

		__sx_var_unset "${__sx_arr_pop0_src_}"
	done

	eval "${__sx_arr_pop0_arr_}_len=${__sx_arr_pop0_len_}"
	__sx_var_touch "${__sx_arr_pop0_arr_}"

	unset __sx_arr_pop0_arr_ __sx_arr_pop0_len_ __sx_arr_pop0_dest_ __sx_arr_pop0_src_
}

### sx_var_is_set - 変数が設定されているか確認する
##
## 使い方:
##   sx_var_is_set 変数名1 [変数名2 ...]
##
## 終了ステータス:
##    0  すべて設定されている (SX_EX_OK)
##    1  未設定の変数が含まれる
##   64  変数名が無効 (SX_EX_USAGE)
sx_var_is_set() {
	sx_var_is_name "${@}" || return "${SX_EX_USAGE}"
	__sx_var_is_set "${@}" || return "${?}"
}

### __sx_var_is_set - 変数が設定されているか確認する（内部用）
##
## 使い方:
##   __sx_var_is_set 変数名1 [変数名2 ...]
##
## 説明:
##   引数で指定されたすべての変数が設定されているか確認する。
##   引数チェックは行わない。
__sx_var_is_set() {
	for __sx_var_is_set_arg_ in "${@}"; do
		if eval sx_str_eq "\"\${${__sx_var_is_set_arg_}+X}\"" '""'; then
			unset __sx_var_is_set_arg_
			return 1
		fi

		unset __sx_var_is_set_arg_
	done
}

### sx_var_has_val - 変数が値を持ち、かつ空でないか確認する
##
## 使い方:
##   sx_var_has_val 変数名1 [変数名2 ...]
##
## 終了ステータス:
##    0  すべて値があり、空でない (SX_EX_OK)
##    1  設定されていない、または空の変数が含まれる
##   64  変数名が無効 (SX_EX_USAGE)
sx_var_has_val() {
	sx_var_is_name "${@}" || return "${SX_EX_USAGE}"
	__sx_var_has_val "${@}" || return "${?}"
}

### __sx_var_has_val - 変数が値を持ち、かつ空でないか確認する（内部用）
##
## 使い方:
##   __sx_var_has_val 変数名1 [変数名2 ...]
##
## 説明:
##   引数で指定されたすべての変数が値を持ち、空でないか確認する。
##   引数チェックは行わない。
__sx_var_has_val() {
	for __sx_var_has_val_arg_ in "${@}"; do
		if eval ! sx_str_eq "\"\${${__sx_var_has_val_arg_}:+X}\"" X; then
			unset __sx_var_has_val_arg_
			return 1
		fi

		unset __sx_var_has_val_arg_
	done
}

### sx_var_is_empty - 変数が設定されており、かつ空か確認する
##
## 使い方:
##   sx_var_is_empty 変数名1 [変数名2 ...]
##
## 終了ステータス:
##    0  すべて空である (SX_EX_OK)
##    1  設定されていない、または空でない変数が含まれる
##   64  変数名が無効 (SX_EX_USAGE)
sx_var_is_empty() {
	sx_var_is_name "${@}" || return "${SX_EX_USAGE}"
	__sx_var_is_empty "${@}" || return "${?}"
}

### __sx_var_is_empty - 変数が設定されており、かつ空か確認する（内部用）
##
## 使い方:
##   __sx_var_is_empty 変数名1 [変数名2 ...]
##
## 説明:
##   引数で指定されたすべての変数が空（かつ設定済み）か確認する。
##   引数チェックは行わない。
__sx_var_is_empty() {
	for __sx_var_is_empty_arg_ in "${@}"; do
		if eval ! sx_str_eq "\"\${${__sx_var_is_empty_arg_}+X}\${${__sx_var_is_empty_arg_}-}\"" X; then
			unset __sx_var_is_empty_arg_
			return 1
		fi

		unset __sx_var_is_empty_arg_
	done
}

### sx_var_is_rw - 変数が書き込み可能か確認する
##
## 使い方:
##   sx_var_is_rw 変数名1 [変数名2 ...]
##
## 終了ステータス:
##    0  すべて書き込み可能 (SX_EX_OK)
##    1  読み取り専用が含まれる
##   64  変数名が無効 (SX_EX_USAGE)
sx_var_is_rw() {
	sx_var_is_name "${@}" || return "${SX_EX_USAGE}"
	__sx_var_is_rw "${@}" || return "${?}"
}

### __sx_var_is_rw - 変数が書き込み可能か確認する（内部用）
##
## 使い方:
##   __sx_var_is_rw 変数名1 [変数名2 ...]
##
## 説明:
##   引数で指定されたすべての変数が書き込み可能か確認する。
##   サブシェルの生成を最小限にするため、一括で検証を行う。
__sx_var_is_rw() {
	! sx_str_eq "${#}" 0 || return 0
	( unset -v "${@}" ) 2>/dev/null || return 1
}

### sx_var_is_ro - 変数が読み取り専用か確認する
##
## 使い方:
##   sx_var_is_ro 変数名1 [変数名2 ...]
##
## 終了ステータス:
##    0  すべて読み取り専用 (SX_EX_OK)
##    1  書き込み可能な変数が含まれる
##   64  変数名が無効 (SX_EX_USAGE)
sx_var_is_ro() {
	sx_var_is_name "${@}" || return "${SX_EX_USAGE}"
	__sx_var_is_ro "${@}" || return "${?}"
}

### __sx_var_is_ro - 変数が読み取り専用か確認する（内部用）
##
## 使い方:
##   __sx_var_is_ro 変数名1 [変数名2 ...]
##
## 説明:
##   引数で指定されたすべての変数が読み取り専用か確認する。
##   引数チェックは行わない。
__sx_var_is_ro() {
	for __sx_var_is_ro_arg_ in "${@}"; do
		if (eval "${__sx_var_is_ro_arg_}"=) 2>/dev/null; then
			unset __sx_var_is_ro_arg_
			return 1
		fi

		unset __sx_var_is_ro_arg_
	done
}


### sx_var_is_name - 変数名として有効か確認する
##
## 使い方:
##   sx_var_is_name [文字列1 [文字列2 ...]]
##
## 終了ステータス:
##    0  すべて有効な変数名 (SX_EX_OK)
##    1  無効な変数名が含まれる
sx_var_is_name() {
	for __sx_var_is_name_arg in "${@}"; do
		case "${__sx_var_is_name_arg}" in
			'' | [0-9]* | *[!_A-Za-z0-9]*)
				unset __sx_var_is_name_arg
				return 1
				;;
		esac
	done

	unset __sx_var_is_name_arg
}

### sx_var_copyls - 変数のコピー用代入式リストを生成する
##
## 使い方:
##   sx_var_copyls 結果変数名 [変数名1 [変数名2 [変数名3 ...]]]
##
## 説明:
##   与えられた変数名列に対する右方向の連鎖コピーで必要となる、
##   スペース区切りの代入式リストを生成して結果変数に格納する。
##   例: v1 v2 v3 の場合は、v2=v1 と v3=v2 に相当する代入式群を生成する。
##   コピー元が sx 配列である場合は、関連するすべての要素も含めてリストに含める。
##   生成されたリストは eval set -- 等で利用できる。
##   変数名が 1 個以下の場合は空文字列を格納する。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
sx_var_copyls() {
	sx_var_is_name "${@}" || return "${SX_EX_USAGE}"
	sx_var_rw_chk "${1-}" || return "${?}"

	__sx_var_copyls "${@}"
}

### __sx_var_copyls - 変数のコピー用代入式リストを生成する（内部用）
##
## 使い方:
##   __sx_var_copyls 結果変数名 [変数名1 [変数名2 [変数名3 ...]]]
##
## 説明:
##   sx_var_copyls の内部実装。
##   変数名列から右方向連鎖コピー用の代入式リストを生成する。
##   引数チェックは行わない。
__sx_var_copyls() {
	__sx_var_copyls_res_="${1}"
	shift

	__sx_var_copyls_out_=
	__sx_var_copyls_i_="${#}"
	__sx_arg_quote __sx_var_copyls_esc_ "${@}"

	while sx_num_is_lt 1 "${__sx_var_copyls_i_}"; do
		eval "__sx_var_copyls_dest_=\"\${${__sx_var_copyls_i_}}\""
		eval "__sx_var_copyls_src_=\"\${$((__sx_var_copyls_i_ - 1))}\""

		__sx_var_list_dep __sx_var_copyls_ls_ "${__sx_var_copyls_src_}"
		eval set -- "${__sx_var_copyls_ls_}"

		for __sx_var_copyls_name_ in "${@}"; do
			__sx_var_copyls_out_="${__sx_var_copyls_out_} ${__sx_var_copyls_dest_}${__sx_var_copyls_name_#${__sx_var_copyls_src_}}=${__sx_var_copyls_name_}"
		done

		eval set -- "${__sx_var_copyls_esc_}"
		__sx_var_copyls_i_="$((__sx_var_copyls_i_ - 1))"
	done

	__sx_var_set "${__sx_var_copyls_res_}=${__sx_var_copyls_out_}"
	unset __sx_var_copyls_res_ __sx_var_copyls_out_ __sx_var_copyls_i_ __sx_var_copyls_esc_ __sx_var_copyls_ls_ __sx_var_copyls_dest_ __sx_var_copyls_src_ __sx_var_copyls_name_
}

### sx_util_eval - 文字列をシェルコマンドとして実行する
##
## 使い方:
##   sx_util_eval コマンド文字列
##
## 説明:
##   引数で渡された文字列を eval を用いて実行する。
##   直接的な eval の使用を避け、意図を明確にするためのラッパー。
sx_util_eval() {
	eval "${1}"
}

### sx_arg_join - 引数を指定された区切り文字で結合する
##
## 使い方:
##   sx_arg_join 結果変数名 区切り文字 [値 ...]
##
## 説明:
##   指定された値を区切り文字で結合した文字列を作成して結果変数に格納する。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
sx_arg_join() {
	sx_var_rw_chk "${1-}" || return "${?}"

	__sx_arg_join "${@}"
}

### __sx_arg_join - 引数を指定された区切り文字で結合する（内部用）
##
## 使い方:
##   __sx_arg_join 結果変数名 区切り文字 [値 ...]
##
## 説明:
##   引数チェックを行わずに結合処理を行う。
__sx_arg_join() {
	__sx_arg_join_res_="${1}"
	__sx_arg_join_sep_="${2-}"
	__sx_arg_join_out_=
	shift ${2+2}

	for __sx_arg_join_arg_ in "${@}"; do
		__sx_arg_join_out_="${__sx_arg_join_out_}${__sx_arg_join_sep_}${__sx_arg_join_arg_}"
	done

	__sx_var_set "${__sx_arg_join_res_}=${__sx_arg_join_out_#${__sx_arg_join_sep_}}"

	unset __sx_arg_join_res_ __sx_arg_join_sep_ __sx_arg_join_out_ __sx_arg_join_arg_
}

### sx_arg_quote - 引数をシングルクォートで囲み、スペース区切りで結合する
##
## 使い方:
##   sx_arg_quote 結果変数名 [値 ...]
##
## 説明:
##   指定された値をそれぞれシングルクォートで囲み（内部のシングルクォートはエスケープ）、
##   スペース区切りで順方向に結合した文字列を作成して結果変数に格納する。
##   作成された文字列は eval 等で安全に位置パラメータに戻すことができる。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
sx_arg_quote() {
	sx_var_rw_chk "${1-}" || return "${?}"

	__sx_arg_quote "${@}"
}

### __sx_arg_quote - 引数をシングルクォートで囲み、スペース区切りで結合する（内部用）
##
## 使い方:
##   __sx_arg_quote 結果変数名 [値 ...]
##
## 説明:
##   引数チェックを行わずにクォート結合処理を行う。
__sx_arg_quote() {
	__sx_arg_quote_out_=
	__sx_arg_quote_res_="${1}"
	shift

	for __sx_arg_quote_arg_ in "${@}"; do
		__sx_str_sub __sx_arg_quote_esc_ "${__sx_arg_quote_arg_}" "'" "'\\''"
		__sx_arg_quote_out_="${__sx_arg_quote_out_} '${__sx_arg_quote_esc_}'"
	done

	__sx_var_set "${__sx_arg_quote_res_}=${__sx_arg_quote_out_# }"

	unset __sx_arg_quote_res_ __sx_arg_quote_out_ __sx_arg_quote_arg_ __sx_arg_quote_esc_
}

### sx_arg_rquote - 引数を逆順にシングルクォートで囲み、スペース区切りで結合する
##
## 使い方:
##   sx_arg_rquote 結果変数名 [値 ...]
##
## 説明:
##   指定された値をそれぞれシングルクォートで囲み、
##   逆順（最後の引数が先頭）にスペース区切りで結合した文字列を作成して結果変数に格納する。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
sx_arg_rquote() {
	sx_var_rw_chk "${1-}" || return "${?}"

	__sx_arg_rquote "${@}"
}

### __sx_arg_rquote - 引数を逆順にシングルクォートで囲み、スペース区切りで結合する（内部用）
##
## 使い方:
##   __sx_arg_rquote 結果変数名 [値 ...]
##
## 説明:
##   引数チェックを行わずに逆順クォート結合処理を行う。
__sx_arg_rquote() {
	__sx_arg_rquote_out_=
	__sx_arg_rquote_res_="${1}"
	shift

	for __sx_arg_rquote_arg_ in "${@}"; do
		__sx_str_sub __sx_arg_rquote_esc_ "${__sx_arg_rquote_arg_}" "'" "'\\''"
		__sx_arg_rquote_out_=" '${__sx_arg_rquote_esc_}'${__sx_arg_rquote_out_}"
	done

	__sx_var_set "${__sx_arg_rquote_res_}=${__sx_arg_rquote_out_# }"

	unset __sx_arg_rquote_res_ __sx_arg_rquote_out_ __sx_arg_rquote_arg_ __sx_arg_rquote_esc_
}

### __sx_arg_norm - 引数リスト内の数値をプレースホルダに展開して正規化する（内部用）
##
## 使い方:
##   __sx_arg_norm 結果変数名 プレースホルダ [引数...]
##
## 説明:
##   引数リストを走査し、数値 N があればそれを N 個のプレースホルダに展開する。
##   数値以外の文字列はそのまま残す。
__sx_arg_norm() {
	__sx_arg_norm_res_="${1}"
	sx_arg_quote __sx_arg_norm_pl_ "${2-}"
	shift ${2+2}

	__sx_arg_norm_out_=
	for __sx_arg_norm_arg_ in "${@}"; do
		if sx_num_is_uint "${__sx_arg_norm_arg_}"; then
			# 数値 N を N 個のプレースホルダに展開
			__sx_str_rep __sx_arg_norm_tmp_ " ${__sx_arg_norm_pl_}" "${__sx_arg_norm_arg_}"
			__sx_arg_norm_out_="${__sx_arg_norm_out_}${__sx_arg_norm_tmp_}"
		else
			sx_arg_quote __sx_arg_norm_tmp_ "${__sx_arg_norm_arg_}"
			__sx_arg_norm_out_="${__sx_arg_norm_out_} ${__sx_arg_norm_tmp_}"
		fi
	done

	# 先頭の余計なスペースを削って結果変数に格納
	__sx_var_set "${__sx_arg_norm_res_}=${__sx_arg_norm_out_# }"

	unset __sx_arg_norm_res_ __sx_arg_norm_pl_ __sx_arg_norm_out_ __sx_arg_norm_arg_ __sx_arg_norm_tmp_
}
