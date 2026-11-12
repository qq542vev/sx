#!/bin/sh
# shellcheck disable=SC2016 # m4入力とeval用のコードは呼び出し先で展開する。
# shellcheck disable=SC2288 # Parametersの各行は入力データである。

eval "$(shellspec - -c) exit 1"

Describe '文字集合の引用済み引数列'
  check_str_args() {
    namespace=${4-STR}
    # 比較元は別シェルで単独モジュールを読み、末尾が引用符の引数列と区別する。
    original=$(
      sxtest_load "./build/modules/SX_${namespace}_${1}.sh" || exit
      eval 'printf %s "${SX_'"${namespace}_${1}"'}"'
    ) || return
    sxtest_load "./build/modules/SX_${namespace}_${1}_ARGS.sh" || return
    eval 'args=${SX_'"${namespace}_${1}"'_ARGS}'

    macro_args=$(printf 'M_%s_%s_ARGS\n' "${namespace}" "${1}" | m4 -- m4/common.m4 -) || return
    case "${args}" in "${macro_args}") ;; *) return 1;; esac

    # 7ビットは3文字、8ビット側は7文字の表現にスペース1文字を挟む。
    low_count=${2} high_count=${3}
    case "${#args}" in "$((4 * low_count + 8 * high_count - 1))") ;; *) return 1;; esac
    count=$((low_count + high_count))
    remaining=${args} joined=
    IFS=:
    eval 'set --' "${args}"
    case "${#}" in "${count}") ;; *) return 1;; esac
    for letter do
      case "${#letter}" in 1) ;; *) return 1;; esac
      joined=${joined}${letter}
      case "${low_count}" in
        0)
          token=${remaining%"${remaining#???????}"}
          case "${token}" in "\$'\x"[89ABCDEF][0123456789ABCDEF]"'") ;; *) return 1;; esac
          ;;
        *)
          case "${letter}" in "'") token="\"'\"";; *) token="'${letter}'";; esac
          low_count=$((low_count - 1))
          ;;
      esac
      case "${remaining}" in
        "${token}") remaining=;;
        "${token} "*) remaining=${remaining#"${token} "};;
        *) return 1;;
      esac
      # printfの文字数値変換はループの後に一括で行う。
      set -- "${@}" "'${letter}"
    done
    case "${remaining}:${low_count}" in :0) ;; *) return 1;; esac
    case "${joined}" in "${original}") ;; *) return 1;; esac
    shift "${count}"
    ordinals=$(printf '%d\n' "${@}") || return
    previous=0
    while IFS= read -r ordinal; do
      case "$((ordinal > previous && ordinal <= 255))" in 1) ;; *) return 1;; esac
      previous=${ordinal}
    done <<EOF
${ordinals}
EOF
  }

  check_str_args_readonly() {
    sxtest_load "./build/modules/SX_${2-STR}_${1}_ARGS.sh" || return
    if (eval "SX_${2-STR}_${1}_ARGS=changed") 2>/dev/null; then
      return 1
    fi
  }

  # 名前、7ビット文字数、8ビット側の文字数、名前空間（省略時STR）。
  Parameters
    BLANK 2 0
    SPACE 6 0
    CNTRL 32 0
    C0 31 0
    C1 0 32
    CONTROL 32 32
    GR 0 96
    BIN 2 0
    OCT 8 0
    DIGIT 10 0
    XDIGIT 22 0
    UPPER 26 0
    LOWER 26 0
    PUNCT 32 0
    ALPHA 52 0
    ALNUM 62 0
    WORD 63 0
    ALUND 53 0
    GRAPH 94 0
    GRAPHIC 94 96
    PRINT 95 0
    PRINTABLE 95 96
    ASCII 127 0
    NONASCII 0 128
    BYTE 127 128
    SP_NORM 4 0 GLOB
    SP_BRKT 9 0 GLOB
    UNRESERVED 66 0 URI
    GEN_DELIMS 7 0 URI
    SUB_DELIMS 11 0 URI
    RESERVED 18 0 URI
    PCHAR 79 0 URI
    USERINFO 78 0 URI
    REG_NAME 77 0 URI
    SEGMENT_NZ_NC 78 0 URI
    QUERY 81 0 URI
    FRAGMENT 81 0 URI
    SCHEME 65 0 URI
    SCHEME_FIRST 52 0 URI
  End

  It 'マクロと定数の引用形式が一致し、IFSに依存せず元の集合をバイト値の昇順で復元すること'
    When call check_str_args "${1}" "${2}" "${3}" "${4-STR}"
    The status should be success
  End

  It '引用済み引数列を読み取り専用で保持すること'
    When call check_str_args_readonly "${1}" "${4-STR}"
    The status should be success
  End
End
