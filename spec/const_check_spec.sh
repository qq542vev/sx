#!/bin/sh
# shellcheck disable=SC3003
# 制御文字の期待値にはPOSIX.1-2024のドル単一引用符を使用する。

eval "$(shellspec - -c) exit 1"

Describe 'sx_const_check'
  # readonly属性は同じシェルで検査する。上書き指定のファイルもここで一度だけ読み込む。
  sxtest_load ./build/modules/sx_var_is_ro.sh

  # SX_STR_WORDとSX_CFG_META_DEF_SKIP_CHKは上のモジュールに含まれるため再定義しない。
  # 定数チェックでは、残りの定数の単独モジュールを同じシェルに読み込む。
  case "${SXTEST_LOAD_MOD+x}" in
    '')
      sxtest_load ./build/modules/SX_CFG_META_DEF_ARR_HOLE.sh
      sxtest_load ./build/modules/SX_CFG_META_DEF_NUM_RANGE.sh
      sxtest_load ./build/modules/SX_CFG_META_DEF_SEP.sh
      sxtest_load ./build/modules/SX_CFG_META_DEF_SIG_ARR.sh
      sxtest_load ./build/modules/SX_CFG_META_DESC_ARR_HOLE.sh
      sxtest_load ./build/modules/SX_CFG_META_DESC_NUM_RANGE.sh
      sxtest_load ./build/modules/SX_CFG_META_DESC_SEP.sh
      sxtest_load ./build/modules/SX_CFG_META_DESC_SIG_ARR.sh
      sxtest_load ./build/modules/SX_CFG_META_DESC_SKIP_CHK.sh
      sxtest_load ./build/modules/SX_CFG_META_NAMES.sh
      sxtest_load ./build/modules/SX_CFG_META_PATTERN_ARR_HOLE.sh
      sxtest_load ./build/modules/SX_CFG_META_PATTERN_NUM_RANGE.sh
      sxtest_load ./build/modules/SX_CFG_META_PATTERN_SEP.sh
      sxtest_load ./build/modules/SX_CFG_META_PATTERN_SIG_ARR.sh
      sxtest_load ./build/modules/SX_CFG_META_PATTERN_SKIP_CHK.sh
      sxtest_load ./build/modules/SX_EX_MSG71.sh
      sxtest_load ./build/modules/SX_EX_MSG73.sh
      sxtest_load ./build/modules/SX_EX_USAGE.sh
      sxtest_load ./build/modules/SX_NUM_BASE10_PREFIX.sh
      sxtest_load ./build/modules/SX_STR_ALNUM.sh
      sxtest_load ./build/modules/SX_STR_ALPHA.sh
      sxtest_load ./build/modules/SX_STR_ASCII.sh
      sxtest_load ./build/modules/SX_STR_NONASCII.sh
      sxtest_load ./build/modules/SX_STR_BIN.sh
      sxtest_load ./build/modules/SX_STR_BLANK.sh
      sxtest_load ./build/modules/SX_STR_CNTRL.sh
      sxtest_load ./build/modules/SX_STR_DEL.sh
      sxtest_load ./build/modules/SX_STR_FS.sh
      sxtest_load ./build/modules/SX_STR_GRAPH.sh
      sxtest_load ./build/modules/SX_STR_LF.sh
      sxtest_load ./build/modules/SX_STR_PRINT.sh
      sxtest_load ./build/modules/SX_STR_PUNCT.sh
      sxtest_load ./build/modules/SX_STR_SOH.sh
      sxtest_load ./build/modules/SX_STR_SPACE.sh
      sxtest_load ./build/modules/SX_STR_ALUND.sh
      ;;
  esac

  It 'SX_EX_USAGE が関数内で定義されていること'
    check() { echo "$SX_EX_USAGE"; }
    When call check
    The stdout should equal "64"
  End

  It '2進数字の文字集合を保持すること'
    When call :
    The variable SX_STR_BIN should equal '01'
  End

  It '2進数字の文字集合が読み取り専用であること'
    When call sx_var_is_ro SX_STR_BIN
    The status should be success
  End

  It '合成された文字集合の値と順序を保持すること'
    When call :
    The variable SX_STR_ALPHA should equal 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'
    The variable SX_STR_ALNUM should equal '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'
    The variable SX_STR_WORD should equal '_0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'
    The variable SX_STR_ALUND should equal '_ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'
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

  It '非ASCII集合が128～255を昇順に含むこと'
    When call :
    The variable SX_STR_NONASCII should equal $'\200\201\202\203\204\205\206\207\210\211\212\213\214\215\216\217\220\221\222\223\224\225\226\227\230\231\232\233\234\235\236\237\240\241\242\243\244\245\246\247\250\251\252\253\254\255\256\257\260\261\262\263\264\265\266\267\270\271\272\273\274\275\276\277\300\301\302\303\304\305\306\307\310\311\312\313\314\315\316\317\320\321\322\323\324\325\326\327\330\331\332\333\334\335\336\337\340\341\342\343\344\345\346\347\350\351\352\353\354\355\356\357\360\361\362\363\364\365\366\367\370\371\372\373\374\375\376\377'
  End

  It '非ASCII集合が読み取り専用であること'
    When call sx_var_is_ro SX_STR_NONASCII
    The status should be success
  End

  It '引用符を含む定数と空の定数を保持すること'
    When call :
    The variable SX_STR_PUNCT should equal $'!"#$%&\'()*+,-./:;<=>?@[\\]^_`{|}~'
    The variable SX_EX_MSG71 should equal "EX_OSERR(71): system error (e.g., can't fork)"
    The variable SX_EX_MSG73 should equal "EX_CANTCREAT(73): can't create (user) output file"
    The variable SX_NUM_BASE10_PREFIX should equal ''
    The variable SX_CFG_META_DEF_ARR_HOLE should equal ''
  End

  It '既定の配列署名の値を保持すること'
    When call :
    The variable SX_CFG_META_DEF_SIG_ARR should equal 'array-sx-sig-27c9d9d5-763d-4c3e-862d-a2f270928a38-5f8a2b1c'
  End

  It '設定項目名の一覧を公開すること'
    When call :
    The variable SX_CFG_META_NAMES should equal 'SIG_ARR SKIP_CHK NUM_RANGE SEP ARR_HOLE'
  End

  It '設定値の受理パターンを公開すること'
    When call :
    The variable SX_CFG_META_PATTERN_SIG_ARR should equal '?*'
    The variable SX_CFG_META_PATTERN_SKIP_CHK should equal '[01]'
    The variable SX_CFG_META_PATTERN_NUM_RANGE should equal '32|64|128'
    The variable SX_CFG_META_PATTERN_SEP should equal '?*'
    The variable SX_CFG_META_PATTERN_ARR_HOLE should equal '*'
  End

  It '設定のメタ情報が読み取り専用であること'
    When call sx_var_is_ro SX_CFG_META_NAMES \
      SX_CFG_META_DEF_SIG_ARR SX_CFG_META_DEF_SKIP_CHK SX_CFG_META_DEF_NUM_RANGE \
      SX_CFG_META_DEF_SEP SX_CFG_META_DEF_ARR_HOLE \
      SX_CFG_META_PATTERN_SIG_ARR SX_CFG_META_PATTERN_SKIP_CHK SX_CFG_META_PATTERN_NUM_RANGE \
      SX_CFG_META_PATTERN_SEP SX_CFG_META_PATTERN_ARR_HOLE \
      SX_CFG_META_DESC_SIG_ARR SX_CFG_META_DESC_SKIP_CHK SX_CFG_META_DESC_NUM_RANGE \
      SX_CFG_META_DESC_SEP SX_CFG_META_DESC_ARR_HOLE
    The status should be success
  End
End
