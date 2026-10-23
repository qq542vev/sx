# shellcheck shell=sh

### sxtest_setup - 別シェルで補助処理を実行し、指定した変数だけを復元する
## 使い方: sxtest_setup [変数名|名前=値 ...] -- CMD [引数 ...]
## -- の前は出力変数名と子への環境変数指定を混在できる。
## -- と CMD 引数は必須。CMD は単一引数のシェルコードで、空文字列も許可する。
## 入力は名前=値、後続の引数、通常の環境継承で渡す。
## CMD の標準出力は標準エラーへ送り、ダンプだけを復元する。
## 出力先の後始末と書込可否は呼び出し側の責任とし、ロールバックしない。
## 終了ステータス: 0 成功、64 呼出形式不正、その他は子の実行・ダンプ・復元の失敗状態。
## SXTEST_* は補助処理用の予約名で、出力先・環境変数名には指定できない。
sxtest_setup() {
	# CMD とダンプ処理を組み立て、ShellSpec の指定シェルで実行する。
	SXTEST_SETUP_SCRIPT=$(
		SXTEST_SETUP_NAMES=
		# var: 出力先・環境代入、cmd: コード、arg: CMDへの位置引数。
		SXTEST_SETUP_STEP=var
		# シェル指定と起動オプションは既定のIFSで分割する。親のIFSは変更しない。
		unset IFS

		# 元の引数列をforで走査し、位置パラメータをenvの実行引数へ順に組み替える。
		for SXTEST_SETUP_ARG in "${@}"; do
			shift

			case "${SXTEST_SETUP_STEP}" in
				var)
					case "${SXTEST_SETUP_ARG}" in
						--) SXTEST_SETUP_STEP=cmd; continue;;
						*=*) set -- "${@}" "${SXTEST_SETUP_ARG}";;
						*) SXTEST_SETUP_NAMES="${SXTEST_SETUP_NAMES} '${SXTEST_SETUP_ARG}'"
					esac

					case "${SXTEST_SETUP_ARG%%=*}" in '' | [0-9]* | *[!A-Za-z0-9_]* | SXTEST_*)
						exit 64
					esac
					;;
				cmd)
					# SHELLSPEC_SHELLには起動オプションも含まれるため、意図的に分割する。
					# shellcheck disable=SC2086
					set -- "${@}" ${SHELLSPEC_SHELL} -efu -o pipefail -c "
						{
							. ./sx.sh
							${SXTEST_SETUP_ARG}
							sx_var_dump SXTEST_SETUP_DUMP ${SXTEST_SETUP_NAMES}
						} >&2
						printf '%s' \"\${SXTEST_SETUP_DUMP}\"
					" "${SHELLSPEC_SHELL_TYPE}"
					SXTEST_SETUP_STEP=arg
					;;
				arg) set -- "${@}" "${SXTEST_SETUP_ARG}";;
			esac
		done

		# argまで進めばCMD引数を受理済み。空文字列のCMDもこの状態になる。
		case "${SXTEST_SETUP_STEP}" in var | cmd)
			exit 64
		esac

		env "${@}"
	) || eval unset SXTEST_SETUP_SCRIPT ';' "return ${?}"

	# コードを引数へ展開してから管理変数を削除し、指定した出力だけを復元する。
	eval unset SXTEST_SETUP_SCRIPT ';' "${SXTEST_SETUP_SCRIPT}"
}
