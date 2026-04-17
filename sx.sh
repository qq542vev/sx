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

# 配列を識別するためのシグネチャ。外部コマンドに依存せず、十分に長く複雑な値をデフォルトとする。
: "${SX_SIG:=sx-sig-27c9d9d5-763d-4c3e-862d-a2f270928a38-5f8a2b1c}"

### sx_call_with_ifs - IFS を一時的に変更してコマンドを実行する
##
## 使い方:
##   sx_call_with_ifs 新しいIFS コマンド [引数 ...]
##
## 説明:
##   指定された IFS のもとで、残りの引数を単語分割（Word Splitting）を伴って実行する。
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
__sx_call_with_ifs() {
	__sx_call_with_ifs_old_="${IFS-}"
	__sx_call_with_ifs_set_="${IFS+X}"
	__sx_call_with_ifs_opts_="${-}"
	__sx_call_with_ifs_cmd_="${2}"
	IFS="${1}"
	shift 2

	set -f
	set -- "${__sx_call_with_ifs_cmd_}" ${*}

	if ! sx_str_contain "${__sx_call_with_ifs_opts_}" f; then
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
	sx_var_name_check "${@}" || return "${SX_EX_USAGE}"

	__sx_var_is_rw_all "${@}" || return "${?}"
}

__sx_var_is_rw_all() {
	__sx_var_list_related __sx_var_is_rw_all_list_ "${@}"
	set -- "${__sx_var_is_rw_all_list_}"
	unset __sx_var_is_rw_all_list_

	__sx_call_with_ifs ' ' __sx_var_is_rw "${1}" || return "${?}"
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
	if ! sx_var_name_check "${@}"; then
		return "${SX_EX_USAGE}"
	fi

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
			! eval sx_str_eq "\"\${${__sx_var_is_arr_arg_}-}\"" '"array-${SX_SIG}"' ||
			! eval sx_num_is_uint "\"\${${__sx_var_is_arr_arg_}_len-}\""
		then
			unset __sx_var_is_arr_arg_
			return 1
		fi
	done

	unset __sx_var_is_arr_arg_
}

### sx_var_list_related - 指定された変数に関連するすべての変数名を取得する
##
## 使い方:
##   sx_var_list_related 結果変数名 検索対象1 [検索対象2 ...]
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
sx_var_list_related() {
	sx_var_name_check "${1-}" "${@}" || return "${SX_EX_USAGE}"
	__sx_var_is_rw "${1}" || return "${SX_EX_NOPERM}"

	__sx_var_list_related "${@}"
}

### __sx_var_list_related - 指定された変数に関連するすべての変数名を取得する（内部用）
##
## 使い方:
##   __sx_var_list_related 結果変数名 検索対象1 [検索対象2 ...]
##
## 説明:
##   位置パラメータをキューとして利用し、非再帰的に関連変数を収集する。
##   引数チェックは行わない。
__sx_var_list_related() {
	__sx_var_list_related_res_="${1}"
	shift

	__sx_var_list_related_out_=' '

	while ! sx_str_eq "${#}" 0; do
		if sx_str_contain "${__sx_var_list_related_out_}" " ${1} "; then
			shift
			continue
		fi

		__sx_var_list_related_out_="${__sx_var_list_related_out_}${1} "

		if __sx_var_is_arr "${1}"; then
			eval "__sx_var_list_related_len_=\"\${${1}_len}\""
			set -- "${@}" "${1}_len"

			__sx_var_list_related_i_=0
			while ! sx_str_eq "${__sx_var_list_related_i_}" "${__sx_var_list_related_len_}"; do
				set -- "${@}" "${1}_${__sx_var_list_related_i_}"
				__sx_var_list_related_i_=$((__sx_var_list_related_i_ + 1))
			done
		fi

		shift
	done

	__sx_var_list_related_out_="${__sx_var_list_related_out_# }"
	eval "${__sx_var_list_related_res_}=\"\${__sx_var_list_related_out_% }\""

	unset __sx_var_list_related_res_ __sx_var_list_related_out_ __sx_var_list_related_len_ __sx_var_list_related_i_
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
	sx_var_is_rw_all "${@}" || case "${?}" in
		1) return "${SX_EX_NOPERM}";;
		*) return "${?}";;
	esac

	__sx_var_unset "${@}"
}

__sx_var_unset() {
	sx_var_list_related __sx_var_unset_list_ "${@}"

	# 書き込み権限等のチェックは行わず、強制的に削除
	__sx_call_with_ifs ' ' unset -v "${__sx_var_unset_list_}"

	unset __sx_var_unset_list_
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
	__sx_var_set_var=' '

	for __sx_var_set_arg in "${@}"; do
		__sx_var_set_var="${__sx_var_set_var}${__sx_var_set_arg%%=*} "
	done

	__sx_call_with_ifs ' ' sx_var_is_rw "${__sx_var_set_var}" || {
		case "${?}" in
			1) set -- "${SX_EX_NOPERM}";;
			*) set -- "${?}";;
		esac

		unset __sx_var_set_arg __sx_var_set_var
		return "${1}"
	}

	__sx_var_set "${@}"
	unset __sx_var_set_arg __sx_var_set_var
}

__sx_var_set() {
	for __sx_var_set_arg_ in "${@}"; do
		if sx_str_contain "${__sx_var_set_arg_}" "="; then
			eval "${__sx_var_set_arg_%%=*}="'"${__sx_var_set_arg_#*=}"'
		else
			__sx_var_unset "${__sx_var_set_arg_}"
		fi
	done

	unset __sx_var_set_arg_
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
sx_var_list_set() {
	if ! sx_var_name_check "${1-}"; then
		return "${SX_EX_USAGE}"
	fi

	__sx_var_list_set_name="${1}"
	__sx_var_list_set_ret=' '
	__sx_var_list_set_IFS="${IFS}"
	IFS="${SX_CHAR_LF}"

	for __sx_var_list_set_vn in $(set); do
		__sx_var_list_set_vn="${__sx_var_list_set_vn%%=*}"

		if
			sx_var_name_check "${__sx_var_list_set_vn}" && \
			sx_var_is_set "${__sx_var_list_set_vn}" && \
			! sx_str_contain "${__sx_var_list_set_ret}" " ${__sx_var_list_set_vn} "
		then
			__sx_var_list_set_ret="${__sx_var_list_set_ret}${__sx_var_list_set_vn} "
		fi
	done

	IFS="${__sx_var_list_set_IFS}"
	__sx_var_list_set_ret="${__sx_var_list_set_ret# }"
	__sx_var_list_set_ret="${__sx_var_list_set_ret% }"

	eval "${__sx_var_list_set_name}=\"\${__sx_var_list_set_ret}\""

	unset __sx_var_list_set_name __sx_var_list_set_ret __sx_var_list_set_vn __sx_var_list_set_IFS
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
sx_var_list_ro() {
	if ! sx_var_name_check "${1-}"; then
		return "${SX_EX_USAGE}"
	fi

	__sx_var_list_ro_name="${1}"
	__sx_var_list_ro_ret=' '
	__sx_var_list_ro_IFS="${IFS}"
	IFS="${SX_CHAR_LF}"

	for __sx_var_list_ro_vn in $(set); do
		__sx_var_list_ro_vn="${__sx_var_list_ro_vn%%=*}"

		if
			sx_var_name_check "${__sx_var_list_ro_vn}" && \
			sx_var_is_ro "${__sx_var_list_ro_vn}" && \
			! sx_str_contain "${__sx_var_list_ro_ret}" " ${__sx_var_list_ro_vn} "
		then
			__sx_var_list_ro_ret="${__sx_var_list_ro_ret}${__sx_var_list_ro_vn} "
		fi
	done

	IFS="${__sx_var_list_ro_IFS}"
	__sx_var_list_ro_ret="${__sx_var_list_ro_ret# }"
	__sx_var_list_ro_ret="${__sx_var_list_ro_ret% }"

	eval "${__sx_var_list_ro_name}=\"\${__sx_var_list_ro_ret}\""

	unset __sx_var_list_ro_name __sx_var_list_ro_ret __sx_var_list_ro_vn __sx_var_list_ro_IFS
}

### sx_var_copy - 変数の値を右方向に連鎖コピーする
##
## 使い方:
##   sx_var_copy 源泉=先1=先2...
##
## 説明:
##   v1=v2=v3 の場合、v1の値をv2に、v2の元の値をv3にコピーします（右シフト）。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##    1  コピー先が読み取り専用
##   64  引数不正 (SX_EX_USAGE)
sx_var_copy() {
	__sx_var_copy_IFS='='
	__sx_var_swap IFS __sx_var_copy_IFS

	for __sx_var_copy_arg in "${@}"; do
		# 1. バリデーションと書き込みチェック
		# (IFS='=' なので、${__sx_var_copy_arg} は自動的に分割される)
		if sx_str_end_with "${__sx_var_copy_arg}" = || ! sx_var_name_check "${__sx_var_copy_arg%%=*}"; then
			__sx_var_move __sx_var_copy_IFS IFS
			unset __sx_var_copy_arg
			return "${SX_EX_USAGE}"
		fi

		# 2番目以降（コピー先）がすべて書き込み可能かチェック
		! sx_str_contain "${__sx_var_copy_arg}" = || sx_var_is_rw ${__sx_var_copy_arg#*=} || {
			set -- "${?}"
			__sx_var_move __sx_var_copy_IFS IFS
			unset __sx_var_copy_arg
			return "${1}"
		}
	done

	for __sx_var_copy_arg in "${@}"; do
		__sx_var_copy ${__sx_var_copy_arg}
	done

	__sx_var_move __sx_var_copy_IFS IFS
	unset __sx_var_copy_arg
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
## 仕組み:
##   一時変数を使わずに玉突きを解決するため、引数の末尾（右側）から順に
##   「左隣の値を自分に上書きする」という処理を繰り返す。
##   この関数は sx_var_copy から呼び出されることを前提としており、
##   引数はIFSで分割済みの位置パラメータとして受け取る。
__sx_var_copy() {
	# 引数の総数（現在の右端のインデックス）を取得
	__sx_var_copy_i_="${#}"

	# 右端から順に、左隣の値を自分にコピーしていくループ
	while sx_num_is_lt 1 "${__sx_var_copy_i_}"; do
		# 位置パラメータから代入先(dest)と代入元(src)の変数名を取得
		eval "__sx_var_copy_dest_=\"\${${__sx_var_copy_i_}}\""
		eval "__sx_var_copy_src_=\"\${$((__sx_var_copy_i_ - 1))}\""

		# コピー元が設定されている場合はその値を代入、未設定なら代入先もunsetする
		if sx_var_is_set "${__sx_var_copy_src_}"; then
			eval "${__sx_var_copy_dest_}=\"\${${__sx_var_copy_src_}}\""
		else
			unset "${__sx_var_copy_dest_}"
		fi

		# インデックスを一つ左にずらす
		__sx_var_copy_i_="$((__sx_var_copy_i_ - 1))"
	done

	# 内部用変数を掃除
	unset __sx_var_copy_i_ __sx_var_copy_dest_ __sx_var_copy_src_
}

### sx_var_move - 変数を右方向に連鎖移動する
##
## 使い方:
##   sx_var_move 源泉=先1=先2...
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##    1  移動先が読み取り専用
##   64  引数不正 (SX_EX_USAGE)
sx_var_move() {
	__sx_var_move_IFS='='
	__sx_var_swap IFS __sx_var_move_IFS

	for __sx_var_move_arg in "${@}"; do
		case "${__sx_var_move_arg}" in
			'' | *=)
				__sx_var_move __sx_var_move_IFS IFS
				unset __sx_var_move_arg
				return "${SX_EX_USAGE}"
				;;
		esac

		# 書き込みチェック
		sx_var_is_rw ${__sx_var_move_arg} || {
			set -- "${?}"
			__sx_var_move __sx_var_move_IFS IFS
			unset __sx_var_move_arg
			return "${1}"
		}
	done

	for __sx_var_move_arg in "${@}"; do
		__sx_var_move ${__sx_var_move_arg}
	done

	__sx_var_move __sx_var_move_IFS IFS
	unset __sx_var_move_arg
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

	unset "${1}"
}

### sx_var_swap - 変数を右方向にローテーションする
##
## 使い方:
##   sx_var_swap 変数1=変数2=変数3...
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##    1  変数が読み取り専用
##   64  引数不正 (SX_EX_USAGE)
sx_var_swap() {
	__sx_var_swap_IFS='='
	__sx_var_swap IFS __sx_var_swap_IFS

	for __sx_var_swap_arg in "${@}"; do
		case "${__sx_var_swap_arg}" in
			'' | *=)
				__sx_var_move __sx_var_swap_IFS IFS
				unset __sx_var_swap_arg
				return "${SX_EX_USAGE}"
				;;
		esac

		# 書き込みチェック
		sx_var_is_rw ${__sx_var_swap_arg} || {
			set -- "${?}"
			__sx_var_move __sx_var_swap_IFS IFS
			unset __sx_var_swap_arg
			return "${1}"
		}
	done

	for __sx_var_swap_arg in "${@}"; do
		__sx_var_swap ${__sx_var_swap_arg}
	done

	__sx_var_move __sx_var_swap_IFS IFS
	unset __sx_var_swap_arg
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
	set -- __sx_var_swap_end_ "${@}"

	# 最後の引数（変数名）の値を取得して __sx_var_swap_end_ に格納する
	eval "__sx_var_swap_end_=\"\${${#}}\""

	if sx_var_is_set "${__sx_var_swap_end_}"; then
		eval "__sx_var_swap_end_=\"\${${__sx_var_swap_end_}}\""
	else
		unset __sx_var_swap_end_
	fi

	__sx_var_move "${@}"
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
		if sx_str_eq "${__sx_str_any_target}" "${__sx_str_any_arg}"; then
			unset __sx_str_any_target __sx_str_any_arg
			return "${SX_EX_OK}"
		fi
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
##   指定された配列の要素および長さ保持変数 (${配列名}_len) が書き込み可能か確認する。
##   引数なしの場合: 0 から ${配列名}_len までの全要素を確認。
##   個数が省略された場合: 開始インデックスから ${配列名}_len までを確認。
##
## 終了ステータス:
##    0  すべて書き込み可能 (SX_EX_OK)
##    1  書き込み不可が含まれる
##   64  引数不正 (SX_EX_USAGE)
sx_arr_is_rw() {
	__sx_var_is_rw IFS || return "${SX_EX_NOPERM}"
	sx_var_name_check "${1-}" || return "${SX_EX_USAGE}"

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

__sx_arr_is_rw() {
	__sx_arr_is_rw_name_="${1}"
	__sx_arr_is_rw_chk_="${1}_len "
	shift

	! sx_str_eq "${#}" 0 || set -- 0

	if sx_str_eq "$((${#} % 2))" 1; then
		if sx_var_is_arr "${__sx_arr_is_rw_name_}"; then
			# 個数が省略された場合は末尾まで
			eval set -- '"${@}"' "\$((${__sx_arr_is_rw_name_}_len - \${${#}}))"
		else
			set -- "${@}" 0
		fi
	fi

	while ! sx_str_eq "${#}" 0; do
		eval 'shift 2;' set -- "${1}" "$((${1} + ${2}))" '"${@}"'

		while sx_num_is_lt "${1}" "${2}"; do
			__sx_arr_is_rw_chk_="${__sx_arr_is_rw_chk_}${__sx_arr_is_rw_name_}_${1} "
			eval 'shift 2;' set -- "$((${1} + 1))" "${2}" '"${@}"'
		done

		shift 2
	done

	set -- "${__sx_arr_is_rw_chk_}"
	unset __sx_arr_is_rw_name_ __sx_arr_is_rw_chk_

	__sx_call_with_ifs ' ' sx_var_is_rw_all "${1}" || return "${?}"
}

#__sx_arr_copy() {
#	# 引数の総数（現在の右端のインデックス）を取得
#	__sx_var_copy_i_="${#}"
#
#	# 右端から順に、左隣の値を自分にコピーしていくループ
#	while sx_num_is_lt 1 "${__sx_var_copy_i_}"; do
#		# 位置パラメータから代入先(dest)と代入元(src)の変数名を取得
#		eval "__sx_var_copy_dest_=\"\${${__sx_var_copy_i_}}\""
#		eval "__sx_var_copy_src_=\"\${$((__sx_var_copy_i_ - 1))}\""
#		eval "__sx_var_copy_len_=\"\${${__sx_var_copy_src_}_len}\""
#
#		__sx_var_copy_j_=0
#		while ! sx_str_eq "${__sx_var_copy_j_}" "${__sx_var_copy_len_}" ; do
#			eval "__sx_var_copy_val_=\"$\"${__sx_var_copy_src_}=\"\${$((__sx_var_copy_i_ - 1))}\""
#			
#			eval "${__sx_var_copy_dest}_"
#		done
#
#		# コピー元が設定されている場合はその値を代入、未設定なら代入先もunsetする
#		if sx_var_is_set "${__sx_var_copy_src_}"; then
#			eval "${__sx_var_copy_dest_}=\"\${${__sx_var_copy_src_}}\""
#		else
#			unset "${__sx_var_copy_dest_}"
#		fi
#
#		# インデックスを一つ左にずらす
#		__sx_var_copy_i_="$((__sx_var_copy_i_ - 1))"
#	done
#
#	# 内部用変数を掃除
#	unset __sx_var_copy_i_ __sx_var_copy_dest_ __sx_var_copy_src_
#
#
#}

### __sx_str_split - 文字列を分割して配列に格納する（内部用）
##
## 使い方:
##   __sx_str_split 配列名 [文字列 [区切り文字]] ...
##
## 説明:
##   指定された文字列を区切り文字で分割し、sxライブラリ形式の配列として格納する。
##   複数の「文字列と区切り文字」のペアを渡すことができ、その場合は一つの配列に
##   順番に追加される。区切り文字が省略された場合はスペースが使用される。
##   この関数は引数の検証や書き込み権限のチェックを行わない。
__sx_str_split() {
	__sx_str_split_name_="${1}"
	shift

	eval "${__sx_str_split_name_}_len=0"

	while ! sx_str_eq "${#}" 0; do
		__sx_str_split_str_="${1}"
		__sx_str_split_sep_="${2- }"

		while sx_str_contain "${__sx_str_split_str_}" "${__sx_str_split_sep_}"; do
			__sx_arr_push "${__sx_str_split_name_}" "${__sx_str_split_str_%%${__sx_str_split_sep_}*}"
			__sx_str_split_str_="${__sx_str_split_str_#*${__sx_str_split_sep_}}"
		done

		__sx_arr_push "${__sx_str_split_name_}" "${__sx_str_split_str_}"
		shift "$((${#} < 2 ? 1 : 2))"
	done

	unset __sx_str_split_name_ __sx_str_split_str_ __sx_str_split_sep_
}

: <<EOF
実装中
sx_arr_gen() {
	sx_var_rw_all "${1-}" || case "${?}" in
		1) return "${SX_EX_NOPERM}";;
		*) return "${?}";;
	esac

	if ! sx_arr_is_rw "${1}" 0 "$((${#} - 1))"; then
		return "${SX_EX_NOPERM}"
	fi

	__sx_arr_gen "${@}"
}

__sx_arr_gen() {
	__sx_var_unset "${1}"
	eval "${1}_len=$((${#} - 1))"
	__sx_arr_push "${@}"
}
EOF
### __sx_arr_push - 配列の末尾に要素を追加する（内部用）
##
## 使い方:
##   __sx_arr_push 配列名 [値 ...]
##
## 説明:
##   指定された配列の末尾に一つ以上の値を追加し、長さを更新する。
##   この関数は引数の検証や書き込み権限のチェックを行わない。
__sx_arr_push() {
	__sx_arr_push_name_="${1}"
	shift

	eval "__sx_arr_push_idx_=\"\${${__sx_arr_push_name_}_len-}\""
	# 現在の長さを取得（未設定や不正な値なら0とみなす）
	if ! sx_num_is_uint "${__sx_arr_push_idx_}"; then
		__sx_arr_push_idx_=0
	fi

	# 値の追加
	for __sx_arr_push_arg_ in "${@}"; do
		eval "${__sx_arr_push_name_}_${__sx_arr_push_idx_}=\"\${__sx_arr_push_arg_}\""
		__sx_arr_push_idx_=$((__sx_arr_push_idx_ + 1))
	done

	# 長さを更新
	eval "${__sx_arr_push_name_}_len=${__sx_arr_push_idx_}"

	unset __sx_arr_push_name_ __sx_arr_push_idx_ __sx_arr_push_arg_
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

	__sx_arr_push_name="${1}"
		eval "__sx_arr_push_len=\"\${${__sx_arr_push_name}_len-}\""

	# 現在の長さを取得（未設定や不正な値なら0とみなす）
	if ! sx_num_is_uint "${__sx_arr_push_len}"; then
		__sx_arr_push_len=0
	fi

	# 書き込み可能チェック（長さ変数と、追加される全要素）
	if ! sx_arr_is_rw "${__sx_arr_push_name}" "${__sx_arr_push_len}" "$((${#} - 1))"; then
		unset __sx_arr_push_name __sx_arr_push_len
		return "${SX_EX_NOPERM}"
	fi

	__sx_arr_push "${@}"

	unset __sx_arr_push_name __sx_arr_push_len
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
	sx_var_name_check "${@}" || return "${SX_EX_USAGE}"
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

### sx_var_has_value - 変数が値を持ち、かつ空でないか確認する
##
## 使い方:
##   sx_var_has_value 変数名1 [変数名2 ...]
##
## 終了ステータス:
##    0  すべて値があり、空でない (SX_EX_OK)
##    1  設定されていない、または空の変数が含まれる
##   64  変数名が無効 (SX_EX_USAGE)
sx_var_has_value() {
	sx_var_name_check "${@}" || return "${SX_EX_USAGE}"
	__sx_var_has_value "${@}" || return "${?}"
}

### __sx_var_has_value - 変数が値を持ち、かつ空でないか確認する（内部用）
##
## 使い方:
##   __sx_var_has_value 変数名1 [変数名2 ...]
##
## 説明:
##   引数で指定されたすべての変数が値を持ち、空でないか確認する。
##   引数チェックは行わない。
__sx_var_has_value() {
	for __sx_var_has_value_arg_ in "${@}"; do
		if eval ! sx_str_eq "\"\${${__sx_var_has_value_arg_}:+X}\"" X; then
			unset __sx_var_has_value_arg_
			return 1
		fi

		unset __sx_var_has_value_arg_
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
	sx_var_name_check "${@}" || return "${SX_EX_USAGE}"
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
	sx_var_name_check "${@}" || return "${SX_EX_USAGE}"
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
	sx_var_name_check "${@}" || return "${SX_EX_USAGE}"
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

### sx_var_name_check - 変数名として有効か確認する
##
## 使い方:
##   sx_var_name_check [文字列1 [文字列2 ...]]
##
## 終了ステータス:
##    0  すべて有効な変数名 (SX_EX_OK)
##    1  無効な変数名が含まれる
sx_var_name_check() {
	for __sx_var_name_check_arg in "${@}"; do
		case "${__sx_var_name_check_arg}" in
			'' | [0-9]* | *[!_A-Za-z0-9]*)
				unset __sx_var_name_check_arg
				return 1
				;;
		esac
	done

	unset __sx_var_name_check_arg
}
