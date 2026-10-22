# shellcheck shell=sh

# 準備専用シェルの変数だけを受け取る。全体版の関数は呼び出し元に定義しない。
sx_test_setup() {
  SXTEST_PREP_SCRIPT=$(sx_test_prepare "$@") || return
  if eval "${SXTEST_PREP_SCRIPT}"; then
    unset SXTEST_PREP_SCRIPT
  else
    set -- "$?"
    unset SXTEST_PREP_SCRIPT
    return "$1"
  fi
}

sx_test_prepare() (
  SXTEST_PREP_NAMES=''
  SXTEST_PREP_GLOBALS=''
  SXTEST_PREP_REV=${SX_SYS_REV-0}
  export SXTEST_PREP_REV
  # setは値を引用した代入式を返す。ここでは名前だけを取り出し、実際の値は
  # exportで渡すため、引用符・改行・空文字列をそのまま維持できる。
  while IFS= read -r SXTEST_PREP_LINE; do
    SXTEST_PREP_NAME=${SXTEST_PREP_LINE%%=*}
    case "${SXTEST_PREP_NAME}" in
      '' | [0-9]* | *[!a-zA-Z0-9_]*) continue;;
      SHELLSPEC_* | shellspec_* | SXTEST_* | __*) continue;;
      SX_CFG_META_* | SX_NUM_* | SX_STR_* | SX_ARG_* | SX_EX_*) continue;;
    esac
    eval 'case ${'"${SXTEST_PREP_NAME}"'+X} in X) ;; *) continue;; esac'
    case "${SXTEST_PREP_NAME}" in
      SX_CFG_* | SX_SYS_NUM_* | SX_SYS_REV)
        SXTEST_PREP_GLOBALS="${SXTEST_PREP_GLOBALS} ${SXTEST_PREP_NAME}"
        ;;
    esac
    case "${SXTEST_PREP_NAME}" in SX_SYS_*) continue;; esac
    export "${SXTEST_PREP_NAME?}"
    SXTEST_PREP_NAMES="${SXTEST_PREP_NAMES} ${SXTEST_PREP_NAME}"
  done <<EOF
$(set)
EOF
  export SXTEST_PREP_NAMES SXTEST_PREP_GLOBALS
  sh -efu ./spec/support/prepare_run.sh "$@"
)
