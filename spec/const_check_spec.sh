#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_const_check'
  Include ./sx.sh
  It 'SX_EX_USAGE が関数内で定義されていること'
    check() { echo "$SX_EX_USAGE"; }
    When call check
    The stdout should equal "64"
  End

  It '合成された文字集合の値と順序を保持すること'
    When call :
    The variable SX_STR_ALPHA should equal 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'
    The variable SX_STR_ALNUM should equal '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'
    The variable SX_STR_WORD should equal '_0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'
    The variable SX_STR_SWORD should equal '_ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'
    The variable SX_STR_GRAPH should equal "${SX_STR_PUNCT}${SX_STR_ALNUM}"
    The variable SX_STR_PRINT should equal " ${SX_STR_GRAPH}"
    The variable SX_STR_ASCII should equal "${SX_STR_CNTRL}${SX_STR_PRINT}"
  End

  It '制御文字の値を保持すること'
    When call :
    The variable SX_STR_SOH should equal $'\001'
    The variable SX_STR_LF should equal $'\012'
    The variable SX_STR_FS should equal $'\034'
    The variable SX_STR_DEL should equal $'\177'
    The variable SX_STR_BLANK should equal $'\011 '
    The variable SX_STR_SPACE should equal $'\011\012\013\014\015 '
    The variable SX_STR_CNTRL should equal $'\001\002\003\004\005\006\007\010\011\012\013\014\015\016\017\020\021\022\023\024\025\026\027\030\031\032\033\034\035\036\037\177'
  End

  It '引用符を含む定数と空の定数を保持すること'
    When call :
    The variable SX_STR_PUNCT should equal $'!"#$%&\'()*+,-./:;<=>?@[\\]^_`{|}~'
    The variable SX_EX_MSG71 should equal "EX_OSERR(71): system error (e.g., can't fork)"
    The variable SX_EX_MSG73 should equal "EX_CANTCREAT(73): can't create (user) output file"
    The variable SX_NUM_BASE10_PREFIX should equal ''
    The variable SX_CFG_DEF_ARR_HOLE should equal ''
    The variable SX_CFG_DEF_ARR_REF should equal ''
  End

  It '既定の配列署名をビルド時に合成しても値を保持すること'
    When call :
    The variable SX_CFG_DEF_SIG_ARR should equal "array-${SX_CFG_DEF_SIG_BASE}"
  End
End
