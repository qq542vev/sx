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

### sx_var_set - 変数に値を設定する
##
## 使い方:
##   sx_var_set [-p プレフィックス] [-s サフィックス] [名前=値 ...]
##
## オプション:
##   -p プレフィックス  設定する変数名の先頭に付与する文字列
##   -s サフィックス    設定する変数名の末尾に付与する文字列
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##    1  読み取り専用変数への書き込み失敗
sx_var_set() {
	sx_var_move __sx_var_set_OPTARG=OPTARG __sx_var_set_OPTIND=OPTIND

	while getopts p:s: __sx_var_set_opt; do
		case "${__sx_var_set_opt}" in
			p) __sx_var_set_prefix="${OPTARG}";;
			s) __sx_var_set_suffix="${OPTARG}";;
			*)
				sx_var_move OPTARG=__sx_var_set_OPTARG OPTIND=__sx_var_set_OPTIND
				unset __sx_var_set_opt __sx_var_set_prefix __sx_var_set_suffix
				return "${SX_EX_USAGE}"
				;;
		esac
	done

	shift "$((OPTIND - 1))"

	for __sx_var_set_arg in "${@}"; do
		if ! sx_var_is_writable "${__sx_var_set_prefix-}${__sx_var_set_arg%%=*}${__sx_var_set_suffix-}"; then
			eval 'unset __sx_var_set_opt __sx_var_set_prefix __sx_var_set_suffix __sx_var_set_arg;' return "${?}"
		fi
	done

	for __sx_var_set_arg in "${@}"; do
		if sx_str_contain "${__sx_var_set_arg}" "="; then
			eval "${__sx_var_set_prefix-}${__sx_var_set_arg%%=*}${__sx_var_set_suffix-}="'${__sx_var_set_arg#*=}';
		else
			eval "${__sx_var_set_prefix-}${__sx_var_set_arg}${__sx_var_set_suffix-}=";
		fi
	done

	sx_var_move OPTARG=__sx_var_set_OPTARG OPTIND=__sx_var_set_OPTIND
	unset __sx_var_set_opt __sx_var_set_prefix __sx_var_set_suffix __sx_var_set_arg
}

### sx_var_list_set - 設定されている変数の一覧を表示する
##
## 使い方:
##   sx_var_list_set
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
#sx_var_list_set() {
#	if ! sx_var_name_check "${1-}"; then
#		return "${SX_EX_USAGE}"
#	fi
#
#	__sx_var_list_set_list=$(set)
#
#	readonly -p | while IFS=' =' read -r __sx_var_list_ro_type __sx_var_list_ro_name __sx_var_list_ro_val; do
#	while str_contain "${__sx_var_list_set_list}" "${SH_CHAR_LF}"; do
#		${__sx_var_list_set_list%%${$SH}}
#	set | while IFS='=' read -r __sx_var_list_set_name __sx_var_list_set_val; do
#		sx_var_is_set "${__sx_var_list_set_name}" || continue
#
#		sx_str_contain "${__sx_var_list_set_list-}" " ${__sx_var_list_set_name} " && continue
#
#		printf '%s\n' "${__sx_var_list_set_name}"
#		__sx_var_list_set_list="${__sx_var_list_set_list:- }${__sx_var_list_set_name} "
#	done
#
#	unset __sx_var_list_set_name __sx_var_list_set_val __sx_var_list_set_list
#}

### sx_var_list_readonly - 読み取り専用変数の一覧を表示する
##
## 使い方:
##   sx_var_list_readonly
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
sx_var_list_readonly() {
	readonly -p | while IFS=' =' read -r __sx_var_list_ro_type __sx_var_list_ro_name __sx_var_list_ro_val; do
		case "${__sx_var_list_ro_type}" in
			readonly) sx_var_is_readonly "${__sx_var_list_ro_name}" || continue;;
			*) continue;;
		esac

		sx_str_contain "${__sx_var_list_ro_list-}" " ${__sx_var_list_ro_name} " && continue

		printf '%s\n' "${__sx_var_list_ro_name}"
		__sx_var_list_ro_list="${__sx_var_list_ro_list:- }${__sx_var_list_ro_name} "
	done
	unset __sx_var_list_ro_type __sx_var_list_ro_name __sx_var_list_ro_val __sx_var_list_ro_list
}

### sx_var_copy - 変数の値を別の変数にコピーする
##
## 使い方:
##   sx_var_copy コピー先=コピー元 ...
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##    1  コピー先が読み取り専用
sx_var_copy() {
	for __sx_var_copy_arg in "${@}"; do
		if ! sx_str_contain "${__sx_var_copy_arg}" "="; then
			unset __sx_var_copy_arg; return "${SX_EX_USAGE}"
		fi

		if ! sx_var_name_check "${__sx_var_copy_arg#*=}" || ! sx_var_is_writable "${__sx_var_copy_arg%%=*}"; then
			case "${?}" in
				"${SX_EX_USAGE}")
					unset __sx_var_copy_arg; return "${SX_EX_USAGE}"
					;;
				*)
					unset __sx_var_copy_arg; return 1
					;;
			esac
		fi
	done

	for __sx_var_copy_arg in "${@}"; do
		if sx_var_is_set "${__sx_var_copy_arg#*=}"; then
			eval "${__sx_var_copy_arg%%=*}=\${${__sx_var_copy_arg#*=}}"
		else
			unset "${__sx_var_copy_arg%%=*}"
		fi
	done

	unset __sx_var_copy_arg
}

### sx_var_move - 変数を移動（リネーム）する
##
## 使い方:
##   sx_var_move 移動先=移動元 ...
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##    1  移動先が読み取り専用
sx_var_move() {
	for __sx_var_move_arg in "${@}"; do
		if ! sx_var_is_writable "${__sx_var_move_arg%%=*}"; then
			case "${?}" in
				"${SX_EX_USAGE}")
					unset __sx_var_move_arg; return "${SX_EX_USAGE}"
					;;
				*)
					unset __sx_var_move_arg; return 1
					;;
			esac
		fi
	done

	sx_var_copy "${@}"

	for __sx_var_move_arg in "${@}"; do
		unset "${__sx_var_move_arg#*=}"
	done

	unset __sx_var_move_arg
}

### sx_var_swap - 2つの変数の値を入れ替える
##
## 使い方:
##   sx_var_swap 変数1=変数2 ...
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##    1  変数が読み取り専用
sx_var_swap() {
	for __sx_var_swap_arg in "${@}"; do
		if ! sx_var_is_writable "${__sx_var_swap_arg%%=*}" || ! sx_var_is_writable "${__sx_var_swap_arg#*=}"; then
			case "${?}" in
				"${SX_EX_USAGE}")
					unset __sx_var_swap_arg; return "${SX_EX_USAGE}"
					;;
				*)
					unset __sx_var_swap_arg; return 1
					;;
			esac
		fi

		if sx_var_move "__sx_var_swap_tmp=${__sx_var_swap_arg%%=*}" && \
		   sx_var_move "${__sx_var_swap_arg%%=*}=${__sx_var_swap_arg#*=}" && \
		   sx_var_move "${__sx_var_swap_arg#*=}=__sx_var_swap_tmp"; then
			:
		else
			unset __sx_var_swap_arg __sx_var_swap_tmp; return "${?}"
		fi
	done
	unset __sx_var_swap_arg __sx_var_swap_tmp
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
	case "${#}" in
		0) return "${SX_EX_OK}";;
	esac

	__sx_str_eq_first="${1}"
	shift

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

### sx_str_any - 第一引数が、第二引数以降のいずれかの文字列と完全に一致するか確認する
##
## 使い方:
##   sx_str_any 比較元文字列 比較対象1 [比較対象2 ...]
##
## 終了ステータス:
##    0  いずれかと一致する (SX_EX_OK)
##    1  一つも一致しない（または第二引数以降がない）
##   64  引数が不足している (SX_EX_USAGE)
sx_str_any() {
	if sx_str_eq "${#}" 0; then
		return "${SX_EX_USAGE}"
	fi

	__sx_str_any_target="${1}"
	shift

	for __sx_str_any_arg in "${@}"; do
		case "${__sx_str_any_target}" in
			"${__sx_str_any_arg}")
				unset __sx_str_any_target __sx_str_any_arg
				return "${SX_EX_OK}"
				;;
		esac
	done

	unset __sx_str_any_target __sx_str_any_arg
	return 1
}

### sx_str_contain - 第一引数に、第二引数以降のいずれかの文字列が含まれているか確認する
##
## 使い方:
##   sx_str_contain 検索対象文字列 含まれるべき文字列1 [含まれるべき文字列2 ...]
##
## 終了ステータス:
##    0  いずれかが含まれている (SX_EX_OK)
##    1  一つも含まれていない（または第二引数以降がない）
##   64  引数が不足している (SX_EX_USAGE)
sx_str_contain() {
	if sx_str_eq "${#}" 0; then
		return "${SX_EX_USAGE}"
	fi

	__sx_str_contain_target="${1}"
	shift

	for __sx_str_contain_arg in "${@}"; do
		case "${__sx_str_contain_target}" in
			*"${__sx_str_contain_arg}"*)
				unset __sx_str_contain_target __sx_str_contain_arg
				return "${SX_EX_OK}"
				;;
		esac
	done

	unset __sx_str_contain_target __sx_str_contain_arg
	return 1
}

### sx_str_start_with - 第一引数が、第二引数以降のいずれかの文字列で始まっているか確認する
##
## 使い方:
##   sx_str_start_with 検索対象文字列 開始文字列1 [開始文字列2 ...]
##
## 終了ステータス:
##    0  いずれかで始まっている (SX_EX_OK)
##    1  一つも該当しない（または第二引数以降がない）
##   64  引数が不足している (SX_EX_USAGE)
sx_str_start_with() {
	if sx_str_eq "${#}" 0; then
		return "${SX_EX_USAGE}"
	fi

	__sx_str_sw_target="${1}"
	shift

	for __sx_str_sw_arg in "${@}"; do
		case "${__sx_str_sw_target}" in
			"${__sx_str_sw_arg}"*)
				unset __sx_str_sw_target __sx_str_sw_arg
				return "${SX_EX_OK}"
				;;
		esac
	done

	unset __sx_str_sw_target __sx_str_sw_arg
	return 1
}

### sx_str_end_with - 第一引数が、第二引数以降のいずれかの文字列で終わっているか確認する
##
## 使い方:
##   sx_str_end_with 検索対象文字列 終了文字列1 [終了文字列2 ...]
##
## 終了ステータス:
##    0  いずれかで終わっている (SX_EX_OK)
##    1  一つも該当しない（または第二引数以降がない）
##   64  引数が不足している (SX_EX_USAGE)
sx_str_end_with() {
	if sx_str_eq "${#}" 0; then
		return "${SX_EX_USAGE}"
	fi

	__sx_str_ew_target="${1}"
	shift

	for __sx_str_ew_arg in "${@}"; do
		case "${__sx_str_ew_target}" in
			*"${__sx_str_ew_arg}")
				unset __sx_str_ew_target __sx_str_ew_arg
				return "${SX_EX_OK}"
				;;
		esac
	done

	unset __sx_str_ew_target __sx_str_ew_arg
	return 1
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

### sx_arr_is_writable - 配列の指定範囲が書き込み可能か確認する
##
## 使い方:
##   sx_arr_is_writable 配列名 [[終了インデックス [開始インデックス]] ...]
##
## 説明:
##   指定された配列の要素および長さ保持変数 (${配列名}_len) が書き込み可能か確認する。
##   インデックス範囲が指定されない場合は、0 から ${配列名}_len までの全要素を確認する。
##   開始インデックスを省略した場合は 0 とみなされる。
##
## 終了ステータス:
##    0  すべて書き込み可能 (SX_EX_OK)
##    1  書き込み不可が含まれる
##   64  引数不正 (SX_EX_USAGE)
sx_arr_is_writable() {
	if ! sx_var_name_check "${1-}"; then
		return "${SX_EX_USAGE}"
	fi

	__sx_arr_is_writable_name="${1}"
	shift

	if sx_str_eq "${#}" 0 && eval sx_num_is_uint "\"\${${__sx_arr_is_writable_name}_len-}\""; then
		eval set -- "\"\${${__sx_arr_is_writable_name}_len}\"" 0
	elif ! sx_num_is_uint "${@}"; then
		unset __sx_arr_is_writable_name
		return "${SX_EX_USAGE}"
	fi

	if ! sx_var_is_writable "${__sx_arr_is_writable_name}_len"; then
		unset __sx_arr_is_writable_name
		return 1
	fi

	while ! sx_str_eq "${#}" 0; do
		eval "shift $((1 < ${#} ? 2 : 1));" set -- "${1}" "${2-0}" '"${@}"'

		# 各要素のチェック
		while sx_str_eq "$((${2} <= ${1}))" 1; do
			if ! sx_var_is_writable "${__sx_arr_is_writable_name}_${2}"; then
				unset __sx_arr_is_writable_name
				return 1
			fi

			eval "shift $((1 < ${#} ? 2 : 1));" set -- "${1}" "$((${2} + 1))" '"${@}"'
		done

		shift 2
	done

	unset __sx_arr_is_writable_name
	return "${SX_EX_OK}"
}

__sx_arr_push() {
	__sx_arr_push_name="${1}"
	shift

	# 現在の長さを取得（未設定や不正な値なら0とみなす）
	if ! eval sx_num_is_uint "\"\${${__sx_arr_push_name}_len:-}\""; then
		__sx_arr_push_idx=0
	else
		eval "__sx_arr_push_idx=\${${__sx_arr_push_name}_len}"
	fi

	# 値の追加
	for __sx_arr_push_arg in "${@}"; do
		eval "${__sx_arr_push_name}_${__sx_arr_push_idx}=\"\${__sx_arr_push_arg}\""
		__sx_arr_push_idx=$((__sx_arr_push_idx + 1))
	done

	# 長さを更新
	eval "${__sx_arr_push_name}_len=${__sx_arr_push_idx}"

	unset __sx_arr_push_name __sx_arr_push_idx __sx_arr_push_arg
}

### sx_arr_push - 配列の末尾に要素を追加する
##
## 使い方:
##   sx_arr_push 配列名 [値 ...]
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  配列名が無効 (SX_EX_USAGE)
##   77  変数が読み取り専用 (SX_EX_NOPERM)
sx_arr_push() {
	if ! sx_var_name_check "${1-}"; then
		return "${SX_EX_USAGE}"
	fi

	__sx_arr_push_v_name="${1}"

	# 現在の長さを取得（未設定や不正な値なら0とみなす）
	if ! eval sx_num_is_uint "\"\${${__sx_arr_push_v_name}_len:-}\""; then
		__sx_arr_push_v_idx=0
	else
		eval "__sx_arr_push_v_idx=\${${__sx_arr_push_v_name}_len}"
	fi

	# 書き込み可能チェック（長さ変数と、追加される全要素）
	if ! sx_arr_is_writable "${__sx_arr_push_v_name}" \
		$((__sx_arr_push_v_idx + ${#} - 2)) "${__sx_arr_push_v_idx}"; then
		unset __sx_arr_push_v_name __sx_arr_push_v_idx
		return "${SX_EX_NOPERM}"
	fi

	__sx_arr_push "${@}"
	__sx_arr_push_v_ret="${?}"

	unset __sx_arr_push_v_name __sx_arr_push_v_idx
	return "${__sx_arr_push_v_ret}"
}

### sx_var_is_set - 変数が設定されているか確認する
##
## 使い方:
##   sx_var_is_set 変数名
##
## 終了ステータス:
##    0  設定されている (SX_EX_OK)
##    1  設定されていない
##   64  変数名が無効 (SX_EX_USAGE)
sx_var_is_set() {
	sx_var_name_check "${1}" || return "${SX_EX_USAGE}"

	eval "case \"\${${1}+X}\" in '') return 1;; esac"
}

### sx_var_is_unset - 変数が設定されていないか確認する
##
## 使い方:
##   sx_var_is_unset 変数名
##
## 終了ステータス:
##    0  設定されていない (SX_EX_OK)
##    1  設定されている
##   64  変数名が無効 (SX_EX_USAGE)
sx_var_is_unset() {
	sx_var_name_check "${1}" || return "${SX_EX_USAGE}"

	eval "case \"\${${1}+X}\" in 'X') return 1;; esac"
}

### sx_var_has_value - 変数が値を持ち、かつ空でないか確認する
##
## 使い方:
##   sx_var_has_value 変数名
##
## 終了ステータス:
##    0  値があり、空でない (SX_EX_OK)
##    1  設定されていない、または空
##   64  変数名が無効 (SX_EX_USAGE)
sx_var_has_value() {
	sx_var_is_set "${1}" || return "${?}"

	if eval sx_str_eq "\"\${${1}}\"" "''"; then
		return 1
	fi
}

### sx_var_is_empty - 変数が設定されており、かつ空か確認する
##
## 使い方:
##   sx_var_is_empty 変数名
##
## 終了ステータス:
##    0  空である (SX_EX_OK)
##    1  設定されていない、または空でない
##   64  変数名が無効 (SX_EX_USAGE)
sx_var_is_empty() {
	sx_var_is_set "${1}" || return "${?}"

	if ! eval sx_str_eq "\"\${${1}}\"" "''"; then
		return 1
	fi
}

### sx_var_is_writable - 変数が書き込み可能か確認する
##
## 使い方:
##   sx_var_is_writable 変数名
##
## 終了ステータス:
##    0  書き込み可能 (SX_EX_OK)
##    1  読み取り専用
##   64  変数名が無効 (SX_EX_USAGE)
sx_var_is_writable() {
	sx_var_name_check "${1}" || return "${SX_EX_USAGE}"

	(eval "${1}=") 2>/dev/null || return 1
}

### sx_var_is_readonly - 変数が読み取り専用か確認する
##
## 使い方:
##   sx_var_is_readonly 変数名
##
## 終了ステータス:
##    0  読み取り専用 (SX_EX_OK)
##    1  書き込み可能
##   64  変数名が無効 (SX_EX_USAGE)
sx_var_is_readonly() {
	sx_var_name_check "${1}" || return "${SX_EX_USAGE}"

	(! eval "${1}=") 2>/dev/null || return 1
}

### sx_var_name_check - 変数名として有効か確認する
##
## 使い方:
##   sx_var_name_check 文字列
##
## 終了ステータス:
##    0  有効な変数名 (SX_EX_OK)
##    1  無効な変数名
sx_var_name_check() {
	case "${1}" in
		'' | [0-9]* | *[!_A-Za-z0-9]*) return 1;;
	esac
}
