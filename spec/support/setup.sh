# shellcheck shell=sh

### sxtest_setup - 別シェルで準備し、指定した変数だけを復元する
## 使い方: sxtest_setup [変数名 ...] -- CMD [引数 ...]
## CMD は単一引数のシェルコード。入力は引数と通常の環境継承だけで渡す。
## CMD の標準出力は標準エラーへ送り、ダンプだけを復元する。
## 出力先の後始末と書込可否は呼び出し側の責任とし、ロールバックしない。
## 終了ステータス: 0 成功、64 呼出形式不正、その他は準備・ダンプ・復元の失敗状態。
## SXTEST_* は補助処理用の予約名で、出力先には指定できない。
sxtest_setup() {
	SXTEST_SETUP_UNSET='SXTEST_SETUP_UNSET SXTEST_SETUP_NAMES SXTEST_SETUP_SCRIPT'
	SXTEST_SETUP_NAMES=

	while
		case "${1-}" in
			--) break;;
			'' | [0-9]* | *[!A-Za-z0-9_]* | SXTEST_*)
				eval unset "${SXTEST_SETUP_UNSET}"
				return 64
				;;
		esac

		# 検査済みの名前を空白区切りの引数列にする。CMD による IFS の変更に依存しない。
		SXTEST_SETUP_NAMES="${SXTEST_SETUP_NAMES} ${1}"
		shift
	do :; done

	case "${2-}" in '')
		eval unset "${SXTEST_SETUP_UNSET}"
		return 64
	esac

	# CMD とダンプ処理を組み立て、ShellSpec の指定シェルで実行する。
	SXTEST_SETUP_SCRIPT=$(
		unset IFS
		SXTEST_SETUP_COMMAND="
			{
				. ./sx.sh
				${2}
				sx_var_dump SXTEST_SETUP_DUMP ${SXTEST_SETUP_NAMES}
			} >&2
			printf '%s' \"\${SXTEST_SETUP_DUMP}\"
		"
		shift 2
		${SHELLSPEC_SHELL} -efu -o pipefail -c "${SXTEST_SETUP_COMMAND}" "${SHELLSPEC_SHELL_TYPE}" "${@}"
	) || eval unset "${SXTEST_SETUP_UNSET}" ';' "return ${?}"

	eval unset "${SXTEST_SETUP_UNSET}" ';' "${SXTEST_SETUP_SCRIPT}"
}
