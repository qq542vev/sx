# shellcheck shell=sh

### sxtest_setup - 別シェルで準備し、指定した変数だけを復元する
## 使い方: sxtest_setup [変数名 ...] -- CMD [引数 ...]
## CMD は単一引数のシェルコード。入力は引数と通常の環境継承だけで渡す。
## CMD の標準出力は標準エラーへ送り、ダンプだけを復元する。
## 出力先の後始末と書込可否は呼び出し側の責任とし、ロールバックしない。
## 終了ステータス: 0 成功、64 呼出形式不正、その他は準備・ダンプ・復元の失敗状態。
## SXTEST_* は補助処理用の予約名で、出力先には指定できない。
sxtest_setup() {
  SXTEST_SETUP_NAMES=''
  while :; do
    case "$#" in
      0) unset SXTEST_SETUP_NAMES; return 64;;
    esac
    case "$1" in
      --) shift; break;;
      '' | [0-9]* | *[!A-Za-z0-9_]* | SXTEST_*)
        unset SXTEST_SETUP_NAMES
        return 64
        ;;
    esac
    # 検査済みの名前を引用した引数列にする。CMD による IFS の変更に依存しない。
    SXTEST_SETUP_NAMES="${SXTEST_SETUP_NAMES} '${1}'"
    shift
  done
  case "${1-}" in
    '') unset SXTEST_SETUP_NAMES; return 64;;
  esac

  # 単一引用符内の展開は、新しく起動する準備用シェルで行う。
  # shellcheck disable=SC2016
  SXTEST_SETUP_SCRIPT=$(sh -efu -o pipefail -c '
    . ./sx.sh
    SXTEST_SETUP_NAMES=$1
    SXTEST_SETUP_COMMAND=$2
    shift 2
    eval "$SXTEST_SETUP_COMMAND" >&2
    eval "set -- ${SXTEST_SETUP_NAMES}"
    sx_var_dump SXTEST_SETUP_DUMP "$@"
    printf "%s" "$SXTEST_SETUP_DUMP"
  ' sh "$SXTEST_SETUP_NAMES" "$@") || {
    set -- "$?"
    unset SXTEST_SETUP_NAMES SXTEST_SETUP_SCRIPT
    return "$1"
  }
  unset SXTEST_SETUP_NAMES

  if eval "$SXTEST_SETUP_SCRIPT"; then
    unset SXTEST_SETUP_SCRIPT
  else
    set -- "$?"
    unset SXTEST_SETUP_SCRIPT
    return "$1"
  fi
}
