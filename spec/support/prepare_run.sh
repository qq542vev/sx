# shellcheck shell=sh
# SXTEST_PREP_*は呼び出し元が環境変数で渡す。
# shellcheck disable=SC2153

# このファイルは新しいシェルでだけ実行する。
# shellcheck source=/dev/null
. ./sx.sh
SX_SYS_REV=${SXTEST_PREP_REV}
SXTEST_PREP_COMMAND=$1
shift
SXTEST_PREP_ROOTS=''

sx_test_add_roots() {
  for SXTEST_PREP_BIND in "$@"; do
    SXTEST_PREP_BIND=${SXTEST_PREP_BIND%%=*}
    while :; do
      SXTEST_PREP_SEG=${SXTEST_PREP_BIND%%:*}
      SXTEST_PREP_SEG=${SXTEST_PREP_SEG#*@}
      while :; do
        case "${SXTEST_PREP_SEG}" in
          [0-9]*) SXTEST_PREP_SEG=${SXTEST_PREP_SEG#?};;
          *) break;;
        esac
      done
      case "${SXTEST_PREP_SEG}" in
        '' | *[!a-zA-Z0-9_]*) ;;
        *) SXTEST_PREP_ROOTS="${SXTEST_PREP_ROOTS} ${SXTEST_PREP_SEG}";;
      esac
      case "${SXTEST_PREP_BIND}" in
        *:*) SXTEST_PREP_BIND=${SXTEST_PREP_BIND#*:};;
        *) break;;
      esac
    done
  done
}

case "${SXTEST_PREP_COMMAND}" in
  sx_cfg_set | __sx_cfg_set)
    # 読み込み前の明示的な設定指定も引き継ぐ。既定値を補うために全設定を渡さない。
    if [ "$#" -eq 0 ]; then
      sx_test_add_roots SX_CFG_SIG_ARR SX_CFG_SKIP_CHK SX_CFG_NUM_RANGE SX_CFG_SEP \
        SX_CFG_ARR_UPDATE SX_CFG_ARR_HOLE SX_CFG_ARR_REF
    else
      for SXTEST_PREP_ARG in "$@"; do
        sx_test_add_roots "SX_CFG_${SXTEST_PREP_ARG%%=*}"
      done
    fi
    ;;
  sx_var_bind_init | sx_var_unset | sx_var_set) sx_test_add_roots "$@";;
  sx_arr_get) sx_test_add_roots "${1}" "${2}";;
  *) sx_test_add_roots "${1}";;
esac

"${SXTEST_PREP_COMMAND}" "$@"
SXTEST_PREP_OUTPUT_NAMES=${SXTEST_PREP_ROOTS}
for SXTEST_PREP_NAME in ${SXTEST_PREP_NAMES}; do
  for SXTEST_PREP_ROOT in ${SXTEST_PREP_ROOTS}; do
    case "${SXTEST_PREP_NAME}" in
      "${SXTEST_PREP_ROOT}" | "${SXTEST_PREP_ROOT}"_*)
        SXTEST_PREP_OUTPUT_NAMES="${SXTEST_PREP_OUTPUT_NAMES} ${SXTEST_PREP_NAME}"
        break
        ;;
    esac
  done
done
# 派生値は、検証側の対象モジュールが元々定義している変数だけを戻す。
# 未宣言の依存先を準備側の全体版から補わない。
SXTEST_PREP_OUTPUT_NAMES="${SXTEST_PREP_OUTPUT_NAMES} ${SXTEST_PREP_GLOBALS}"
SXTEST_NUM_MIN=${SX_SYS_NUM_MIN}
SXTEST_NUM_MAX=${SX_SYS_NUM_MAX}
# 名前の一覧だけを位置パラメータへ展開する。値はsx_var_dumpが引用する。
# shellcheck disable=SC2086
sx_var_dump SXTEST_PREP_OUTPUT ${SXTEST_PREP_OUTPUT_NAMES} SXTEST_NUM_MIN SXTEST_NUM_MAX
printf '%s\n' "${SXTEST_PREP_OUTPUT}"
