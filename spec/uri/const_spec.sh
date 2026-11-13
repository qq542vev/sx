#!/bin/sh
# shellcheck shell=sh
# RFC 3986 の URI 構成要素の文字集合を検証する。
# shellcheck disable=SC2154

eval "$(shellspec - -c) exit 1"

Describe 'SX_URI_* 定数'
  sxtest_load ./build/modules/sx_var_is_ro.sh

  case "${SXTEST_LOAD_MOD+x}" in
    '')
      sxtest_load ./build/modules/SX_URI_UNRESERVED.sh
      sxtest_load ./build/modules/SX_URI_UNRESERVED_ARGS.sh
      sxtest_load ./build/modules/SX_URI_GEN_DELIMS.sh
      sxtest_load ./build/modules/SX_URI_GEN_DELIMS_ARGS.sh
      sxtest_load ./build/modules/SX_URI_SUB_DELIMS.sh
      sxtest_load ./build/modules/SX_URI_SUB_DELIMS_ARGS.sh
      sxtest_load ./build/modules/SX_URI_RESERVED.sh
      sxtest_load ./build/modules/SX_URI_RESERVED_ARGS.sh
      sxtest_load ./build/modules/SX_URI_PCHAR.sh
      sxtest_load ./build/modules/SX_URI_PCHAR_ARGS.sh
      sxtest_load ./build/modules/SX_URI_USERINFO.sh
      sxtest_load ./build/modules/SX_URI_USERINFO_ARGS.sh
      sxtest_load ./build/modules/SX_URI_REG_NAME.sh
      sxtest_load ./build/modules/SX_URI_REG_NAME_ARGS.sh
      sxtest_load ./build/modules/SX_URI_PORT.sh
      sxtest_load ./build/modules/SX_URI_PORT_ARGS.sh
      sxtest_load ./build/modules/SX_STR_DIGIT.sh
      sxtest_load ./build/modules/SX_URI_SEGMENT_NZ_NC.sh
      sxtest_load ./build/modules/SX_URI_SEGMENT_NZ_NC_ARGS.sh
      sxtest_load ./build/modules/SX_URI_QUERY.sh
      sxtest_load ./build/modules/SX_URI_QUERY_ARGS.sh
      sxtest_load ./build/modules/SX_URI_FRAGMENT.sh
      sxtest_load ./build/modules/SX_URI_FRAGMENT_ARGS.sh
      sxtest_load ./build/modules/SX_URI_SCHEME.sh
      sxtest_load ./build/modules/SX_URI_SCHEME_ARGS.sh
      sxtest_load ./build/modules/SX_URI_SCHEME_FIRST.sh
      sxtest_load ./build/modules/SX_URI_SCHEME_FIRST_ARGS.sh
      sxtest_load ./build/modules/SX_URI_PCT_ENCODED_GLOB.sh
      ;;
  esac

  It '基本集合を RFC 3986 の定義どおり ASCII 順に保持すること'
    When call :
    The variable SX_URI_UNRESERVED should equal "-.0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz~"
    The variable SX_URI_GEN_DELIMS should equal '#/:?@[]'
    The variable SX_URI_SUB_DELIMS should equal "!\$&'()*+,;="
    The variable SX_URI_RESERVED should equal "!#\$&'()*+,/:;=?@[]"
  End

  It 'port を DIGIT と同じ集合として保持すること'
    When call :
    The variable SX_URI_PORT should equal "${SX_STR_DIGIT}"
    The variable SX_URI_PORT should equal '0123456789'
  End

  It 'pchar・userinfo・reg-name・segment-nz-nc を ASCII 順に保持すること'
    When call :
    The variable SX_URI_PCHAR should equal "!\$&'()*+,-.0123456789:;=@ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz~"
    The variable SX_URI_USERINFO should equal "!\$&'()*+,-.0123456789:;=ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz~"
    The variable SX_URI_REG_NAME should equal "!\$&'()*+,-.0123456789;=ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz~"
    The variable SX_URI_SEGMENT_NZ_NC should equal "!\$&'()*+,-.0123456789;=@ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz~"
  End

  It 'query と fragment を同じ集合として保持すること'
    When call :
    The variable SX_URI_QUERY should equal "!\$&'()*+,-./0123456789:;=?@ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz~"
    The variable SX_URI_FRAGMENT should equal "${SX_URI_QUERY}"
  End

  It 'scheme を1文字目と2文字目以降に分けて保持すること'
    When call :
    The variable SX_URI_SCHEME should equal '+-.0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'
    The variable SX_URI_SCHEME_FIRST should equal 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'
  End

  It 'pct-encoded の glob パターンを保持すること'
    When call :
    The variable SX_URI_PCT_ENCODED_GLOB should equal '%[0123456789ABCDEFabcdef][0123456789ABCDEFabcdef]'
  End

  It 'SX_URI_PCT_ENCODED_GLOB をクォートなしで展開して %HH に一致判定できること'
    check_pct_glob() {
      case "${1}" in
        ${SX_URI_PCT_ENCODED_GLOB}) return 0 ;;
        *) return 1 ;;
      esac
    }
    When call check_pct_glob '%9F'
    The status should be success
  End

  It 'SX_URI_PCT_ENCODED_GLOB が不正なパーセント表記に一致しないこと'
    check_pct_glob() {
      case "${1}" in
        ${SX_URI_PCT_ENCODED_GLOB}) return 0 ;;
        *) return 1 ;;
      esac
    }
    When call check_pct_glob '%9G'
    The status should be failure
  End

  It '全 URI 定数が読み取り専用であること'
    When call sx_var_is_ro \
      SX_URI_UNRESERVED SX_URI_UNRESERVED_ARGS \
      SX_URI_GEN_DELIMS SX_URI_GEN_DELIMS_ARGS \
      SX_URI_SUB_DELIMS SX_URI_SUB_DELIMS_ARGS \
      SX_URI_RESERVED SX_URI_RESERVED_ARGS \
      SX_URI_PCHAR SX_URI_PCHAR_ARGS \
      SX_URI_USERINFO SX_URI_USERINFO_ARGS \
      SX_URI_REG_NAME SX_URI_REG_NAME_ARGS \
      SX_URI_PORT SX_URI_PORT_ARGS \
      SX_URI_SEGMENT_NZ_NC SX_URI_SEGMENT_NZ_NC_ARGS \
      SX_URI_QUERY SX_URI_QUERY_ARGS \
      SX_URI_FRAGMENT SX_URI_FRAGMENT_ARGS \
      SX_URI_SCHEME SX_URI_SCHEME_ARGS \
      SX_URI_SCHEME_FIRST SX_URI_SCHEME_FIRST_ARGS \
      SX_URI_PCT_ENCODED_GLOB
    The status should be success
  End
End
